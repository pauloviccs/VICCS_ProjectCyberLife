#!/usr/bin/env node
import { readFile } from 'node:fs/promises';
import { RconClient } from './client.mjs';

const [action, ...args] = process.argv.slice(2);
if (!action || action === '--help') {
  console.log(`Open77 RCON v1 (custom TCP protocol; Node.js 22+)
  node cli.mjs command status
  node cli.mjs request GET /api/dashboard
  node cli.mjs request POST /api/restart '{"delaySeconds":60,"reason":"maintenance"}'
  node cli.mjs discover
  node cli.mjs logs

Environment: OP77_RCON_PASSWORD (required), OP77_RCON_USERNAME (optional),
OP77_RCON_HOST (127.0.0.1), OP77_RCON_PORT (11782), OP77_RCON_TLS=1,
OP77_RCON_CA_FILE (optional PEM CA), OP77_RCON_TLS_NAME (certificate hostname).
Never pass passwords in command-line arguments. Ctrl+C closes the connection.`);
} else {
  let client;
  try {
    const env = process.env;
    client = await RconClient.connect({ host: env.OP77_RCON_HOST, port: Number(env.OP77_RCON_PORT || 11782),
      password: env.OP77_RCON_PASSWORD, username: env.OP77_RCON_USERNAME,
      tls: env.OP77_RCON_TLS === '1' ? { ca: env.OP77_RCON_CA_FILE ? await readFile(env.OP77_RCON_CA_FILE) : undefined,
        servername: env.OP77_RCON_TLS_NAME ?? env.OP77_RCON_HOST ?? 'localhost' } : undefined });
    process.once('SIGINT', () => client.close());
    if (action === 'discover') console.log(JSON.stringify((await client.discover()).operations, null, 2));
    else if (action === 'logs') await client.logs(entry => console.log(JSON.stringify(entry))).result;
    else {
      const result = action === 'command' ? await client.command(args.join(' '))
        : action === 'request' && args.length >= 2 ? await client.request(args[0], args[1], args[2] === undefined ? undefined : JSON.parse(args[2]))
        : (() => { throw new Error('Unknown action. Use --help.'); })();
      console.log(JSON.stringify(result.json ?? { status: result.status, contentType: result.contentType, bytes: result.bytes }, null, 2));
      if (result.status >= 400 || result.json?.ok === false) process.exitCode = 1;
    }
  } catch (error) { console.error(`${error.code ?? 'error'}: ${error.message}`); process.exitCode = 1; }
  finally { client?.close(); }
}
