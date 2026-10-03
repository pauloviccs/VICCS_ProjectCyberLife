# Open77 RCON client

Dependency-free Node.js **22 or later**. Implements Open77's custom TCP protocol,
not Minecraft/Source RCON. No `npm install` or browser runtime is needed.

The full operator, configuration, wire and API documentation is in `docs/rcon.md`
in a server distribution, or [`wiki/rcon.md`](../../../wiki/rcon.md) in the source
repository.

Set `OP77_RCON_PASSWORD` in your shell/secret manager, then:

```sh
node tools/rcon/cli.mjs command status
node tools/rcon/cli.mjs request GET /api/players
node tools/rcon/cli.mjs discover
node tools/rcon/cli.mjs logs
node tools/rcon/cli.mjs --help
```

Dashboard backend example:

```js
import { RconClient } from './tools/rcon/client.mjs';

const rcon = await RconClient.connect({
  host: '127.0.0.1', port: 11782,
  password: process.env.OP77_RCON_PASSWORD,
});
try {
  const dashboard = await rcon.json('GET', '/api/dashboard');
  const players = await rcon.json('GET', '/api/players');
  console.log({ dashboard, players });
} finally { rcon.close(); }
```

`request()` and `command()` resolve to `{status, contentType, headers, bytes,
body, json?}`. Check `status` **and** the body's `ok`/state/error fields.
`json()` additionally throws for HTTP-style errors and `ok:false`.
Protocol failures throw `RconError` with `code`; an incomplete operation is not
successful even if its initial status was 200.

`start(op, fields, options)` returns `{id, result, cancel}`. `call()` returns only
`result`. `logs(onEntry, {after})` returns the same handle; `cancel()` ends that
subscription without closing the connection. A log callback must not await
another call on the **same** connection: callbacks are awaited for backpressure.
Use a separate connection for long-lived logs if slow consumers must not delay
commands. Logs are a bounded recent/live feed, not a durable delivery queue.

Uploads:

```js
const uploadId = await rcon.uploadFile('./vehicle-pack.zip');
const inspected = await rcon.call('request', {
  method: 'POST', path: '/api/mods/inspect?fileName=vehicle-pack.zip',
  uploadId, contentType: 'application/octet-stream',
});
console.log(inspected.status, inspected.json);
```

An upload is consumed by one request. Re-upload for a second operation; abandon
an unused upload with `call('upload.abort', {uploadId})`. Inspection does not
install anything. Follow the required-mod API's review/hash confirmation flow.

For large downloads, pass `onData` to `request()` or `start()` and write each Buffer
to disk/storage. It is awaited, so awaiting a file write provides backpressure.
`onResponse` is called first: reject unwanted status/content type **before** saving.
Without `onData`, the client caps buffered responses at 16 MiB (configurable with
`maxResponseBytes`). Only promote a temporary download after `result` completes.

TLS uses `{tls: {ca: <PEM bytes>, servername: 'rcon.example.net'}}`; omit `ca` for
system trust. Certificate verification cannot be disabled in this helper.

On disconnect, create a new client using credentials and, if needed, the previous
`client.session.sessionToken`. Keep that token server-side. It restores Workshop
plan/job ownership until `expiresAtUtc`, not uploads, log subscriptions or pending
request results. There is **no automatic reconnect or mutation replay**.

Protect your dashboard with its own authentication, authorization, CSRF checks
and an explicit allowlist of actions. Never expose an unrestricted HTTP-to-RCON
proxy, passwords or session tokens to browsers. An RCON credential granting
`console.execute`, resource upload or `*` is powerful server administration.
