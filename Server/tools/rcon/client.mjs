// Open77 RCON v1. Node.js 22+, no dependencies. For trusted dashboard BACKENDS.
import net from 'node:net';
import tls from 'node:tls';
import { createHash } from 'node:crypto';
import { createReadStream } from 'node:fs';
import { stat } from 'node:fs/promises';
import { setTimeout as delay } from 'node:timers/promises';

export class RconError extends Error {
  constructor(code, message, response) { super(message); this.name = 'RconError'; this.code = code; this.response = response; }
}
const deferred = () => { let resolve, reject; const promise = new Promise((a, b) => { resolve = a; reject = b; }); return { promise, resolve, reject }; };

export class RconClient {
  static async connect({ host = '127.0.0.1', port = 11782, password, username, sessionToken,
    tls: tlsOptions, timeoutMs = 10000, maxResponseBytes = 16 * 1024 * 1024 } = {}) {
    if (typeof password !== 'string' || !password) throw new RconError('credentials_required', 'Pass a password from a secret store or environment variable.');
    // Certificate verification stays on. For private PKI pass { ca, servername }.
    if (tlsOptions?.rejectUnauthorized === false) throw new RconError('unsafe_tls', 'Trust the CA instead of disabling certificate verification.');
    const socket = tlsOptions ? tls.connect({ ...tlsOptions, host, port, rejectUnauthorized: true }) : net.connect({ host, port });
    socket.setNoDelay(true);
    const client = new RconClient(socket, maxResponseBytes);
    const timer = setTimeout(() => client.close(new RconError('connect_timeout', 'RCON connection/authentication timed out.')), timeoutMs);
    try {
      client.hello = await client._hello.promise;
      client.session = await client.call('auth', { version: 1, password, username, sessionToken }, { timeoutMs });
      const heartbeatMs = Math.max(1000, Math.min(30000, client.hello.idleTimeoutSeconds * 1000 / 3));
      client._heartbeat = setInterval(() => { if (!client._heartbeatPending) {
        client._heartbeatPending = true;
        client.call('ping').catch(error => client.close(error)).finally(() => { client._heartbeatPending = false; });
      } }, heartbeatMs);
      client._heartbeat.unref();
      return client;
    } catch (error) { client.close(error); throw error; }
    finally { clearTimeout(timer); }
  }

  constructor(socket, maxResponseBytes) {
    this.socket = socket; this.maxResponseBytes = maxResponseBytes;
    this._hello = deferred(); this._pending = new Map(); this._sequence = 0;
    this._sendTail = Promise.resolve(); this._nextSend = 0; this._closed = false;
    this._close = deferred(); this.closed = this._close.promise;
    socket.on('error', error => this.close(new RconError('connection_failed', error.message)));
    this._pump().catch(error => this.close(error));
  }

  async _pump() {
    let buffer = Buffer.alloc(0);
    for await (const chunk of this.socket) {
      buffer = buffer.length ? Buffer.concat([buffer, chunk]) : chunk;
      while (buffer.length >= 4) {
        const size = buffer.readUInt32BE();
        if (size < 2 || size > 4 * 1024 * 1024) throw new RconError('invalid_frame', 'Server returned an invalid frame length.');
        if (buffer.length < size + 4) break;
        const frame = JSON.parse(new TextDecoder('utf-8', { fatal: true }).decode(buffer.subarray(4, size + 4)));
        buffer = buffer.subarray(size + 4);
        await this._receive(frame); // Await consumers: binary/log reads apply TCP backpressure.
      }
    }
    this.close(new RconError('connection_closed', 'RCON disconnected. Query current state before retrying a mutation.'));
  }

  async _receive(frame) {
    if (frame?.id === 0 && frame.type === 'hello') {
      if (this._gotHello || frame.protocol !== 'open77-rcon' || frame.version !== 1 ||
          !Number.isInteger(frame.maxFrameBytes) || frame.maxFrameBytes < 65536 || frame.maxFrameBytes > 4194304 ||
          !Number.isInteger(frame.maxRequestsPerSecond) || frame.maxRequestsPerSecond < 1 ||
          !Number.isInteger(frame.idleTimeoutSeconds) || frame.idleTimeoutSeconds < 1)
        throw new RconError('unsupported_protocol', 'Expected Open77 RCON v1 (not Minecraft/Source RCON).');
      this._gotHello = true; this._hello.resolve(frame); return;
    }
    if (!frame || !Number.isSafeInteger(frame.id) || frame.id < 1) throw new RconError('invalid_frame', 'Invalid response ID.');
    const pending = this._pending.get(frame.id);
    if (!pending) return; // Late terminal/data frame after a local timeout.
    if (frame.type === 'error') {
      this._settle(frame.id, new RconError(frame.error?.code ?? 'operation_failed', frame.error?.message ?? 'Operation failed.')); return;
    }
    if (frame.type === 'result') { this._settle(frame.id, null, frame); return; }
    if (frame.type === 'response') {
      if (pending.response) throw new RconError('invalid_frame', 'Repeated response metadata.');
      pending.response = frame;
      await pending.onResponse?.(frame); return;
    }
    if (frame.type === 'data') {
      if (!pending.response || typeof frame.data !== 'string' || !/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(frame.data))
        throw new RconError('invalid_frame', 'Invalid response data.');
      const data = Buffer.from(frame.data, 'base64'); pending.bytes += data.length;
      if (pending.onData) await pending.onData(data);
      else {
        if (pending.bytes > pending.maxResponseBytes) throw new RconError('response_too_large', 'Use onData to stream this response.');
        pending.chunks.push(data);
      }
      return;
    }
    if (frame.type === 'end') {
      if (!pending.response || frame.bytes !== pending.bytes) throw new RconError('invalid_frame', 'Incomplete response byte count.');
      if (!frame.complete) { this._settle(frame.id, new RconError(frame.error ?? 'incomplete', 'Operation did not complete; inspect state before retrying.', pending.response)); return; }
      const body = pending.onData ? undefined : Buffer.concat(pending.chunks);
      const response = { ...pending.response, bytes: pending.bytes, body };
      if (body?.length && response.contentType?.includes('application/json')) response.json = JSON.parse(body.toString('utf8'));
      this._settle(frame.id, null, response); return;
    }
    throw new RconError('invalid_frame', 'Unknown response frame type.');
  }

  _settle(id, error, value) {
    const pending = this._pending.get(id); if (!pending) return;
    this._pending.delete(id); clearTimeout(pending.timer);
    if (error) pending.reject(error); else pending.resolve(value);
  }

  // start() exposes an ID for cancellation; result resolves after the final frame.
  start(op, fields = {}, { timeoutMs = 65000, onData, onResponse, maxResponseBytes = this.maxResponseBytes } = {}) {
    if (this._closed) throw new RconError('connection_closed', 'Connect again; this client is closed.');
    if (this._pending.size >= 128) throw new RconError('client_busy', 'Too many pending client operations.');
    const id = ++this._sequence;
    const payload = Buffer.from(JSON.stringify({ ...fields, id, op }));
    if (payload.length > (op === 'auth' ? 16384 : this.hello?.maxFrameBytes ?? 65536))
      throw new RconError('frame_too_large', 'Use a staged upload for large bodies.');
    const wait = deferred();
    const pending = { ...wait, chunks: [], bytes: 0, onData, onResponse, maxResponseBytes };
    this._pending.set(id, pending);
    this._sendTail = this._sendTail.then(async () => {
      if (this._closed) return;
      const sleep = this._nextSend - Date.now(); if (sleep > 0) await delay(sleep);
      if (this._closed) return;
      // Serialize writes and pace uploads/polls below the advertised request rate.
      this._nextSend = Date.now() + Math.ceil(1100 / (this.hello?.maxRequestsPerSecond ?? 10));
      if (timeoutMs > 0) pending.timer = setTimeout(() => {
        this._settle(id, new RconError('request_timeout', 'Request timed out; it may already have changed server state.'));
        if (op === 'request' || op === 'command') this.call('cancel', { requestId: id }).catch(() => {});
      }, timeoutMs);
      const frame = Buffer.allocUnsafe(payload.length + 4); frame.writeUInt32BE(payload.length); payload.copy(frame, 4);
      await new Promise((resolve, reject) => this.socket.write(frame, error => error ? reject(error) : resolve()));
    }).catch(error => this.close(error));
    return { id, result: wait.promise, cancel: () => this.call('cancel', { requestId: id }) };
  }

  call(op, fields, options) { return this.start(op, fields, options).result; }
  request(method, path, body, options) { return this.call('request', { method, path, ...(body === undefined ? {} : { body }) }, options); }
  async json(method, path, body) {
    const response = await this.request(method, path, body);
    if (response.status >= 400 || response.json?.ok === false)
      throw new RconError(response.json?.error ?? 'operation_rejected', response.json?.message ?? response.json?.output ?? `Status ${response.status}`, response);
    return response.json;
  }
  command(command) { return this.call('command', { command }); }
  discover() { return this.call('discover'); }

  // The callback receives parsed Warden log objects (seq, ts, level, message).
  // Keep it quick: awaiting another request on THIS connection would deadlock reads.
  logs(onEntry, { after = 0 } = {}) {
    let text = ''; const decoder = new TextDecoder();
    return this.start('request', { method: 'GET', path: `/api/console/stream?after=${encodeURIComponent(after)}` }, {
      timeoutMs: 0,
      onResponse(response) { if (response.status !== 200) throw new RconError('logs_rejected', `Logs returned ${response.status}`); },
      async onData(bytes) {
        text += decoder.decode(bytes, { stream: true });
        let split;
        while ((split = text.indexOf('\n\n')) >= 0) {
          const event = text.slice(0, split); text = text.slice(split + 2);
          const data = event.split('\n').filter(line => line.startsWith('data:')).map(line => line.slice(5).trimStart()).join('\n');
          if (data) await onEntry(JSON.parse(data));
        }
        if (text.length > 1024 * 1024) throw new RconError('invalid_log_event', 'Log event too large.');
      }
    });
  }

  async uploadFile(path) {
    if (this._uploading) throw new RconError('upload_busy', 'Only one upload per connection.');
    this._uploading = true; let uploadId;
    try {
      const info = await stat(path);
      if (!info.isFile() || info.size > this.hello.maxUploadBytes) throw new RconError('upload_too_large', 'Upload is not a regular file or exceeds the server limit.');
      const hash = createHash('sha256'); for await (const chunk of createReadStream(path)) hash.update(chunk);
      ({ uploadId } = await this.call('upload.begin', { bytes: info.size, sha256: hash.digest('hex') }));
      let offset = 0; const chunkBytes = Math.min(192 * 1024, Math.floor((this.hello.maxFrameBytes - 1024) * 3 / 4));
      for await (const chunk of createReadStream(path, { highWaterMark: chunkBytes })) {
        await this.call('upload.chunk', { uploadId, offset, data: chunk.toString('base64') }); offset += chunk.length;
      }
      await this.call('upload.finish', { uploadId }); return uploadId;
    } catch (error) {
      if (uploadId && !this._closed) await this.call('upload.abort', { uploadId }).catch(() => {});
      throw error;
    } finally { this._uploading = false; }
  }

  close(reason = new RconError('client_closed', 'RCON client closed.')) {
    if (this._closed) return;
    this._closed = true; clearInterval(this._heartbeat); this.socket.destroy();
    if (!this._gotHello) this._hello.reject(reason);
    for (const id of this._pending.keys()) this._settle(id, reason);
    this._close.resolve(reason);
  }
}
