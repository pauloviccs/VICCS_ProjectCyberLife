# RCON: authenticated TCP server administration

Open77 RCON lets hosting panels, dashboards, bots and command-line tools operate a
dedicated server without opening Warden's HTTP listener. It uses the **same
administration routes, permissions, validation, audit and game-loop actions as
Warden**, including Workshop and performance capture. It is not limited to console
commands.

The design takes the separate TCP port, password login and request/reply model
from Minecraft RCON. The wire protocol is **Open77 RCON v1**, deliberately custom:
length-prefixed JSON with streamed bodies. Minecraft/Source clients such as
`mcrcon` are **not wire-compatible**. Use the bundled Node.js client, or implement
the framing below. There is no client/game protocol change and no Lua dependency.

## Quick start

Add this root section to `server.jsonc`:

```json
"rcon": {
  "enabled": true,
  "bindAddress": "127.0.0.1",
  "port": 11782,
  "passwordEnvironmentVariable": "OP77_RCON_PASSWORD",
  "permissions": ["*"]
}
```

Set `OP77_RCON_PASSWORD` **in the server process environment** to a random secret
of at least 16 characters; inject it from your host's secret manager or protected
service environment file. Do not commit it in JSON, put it in a URL/command-line
argument, or log it. Restart the server to enable the listener.

The shipped `tools/rcon/client.mjs` and `tools/rcon/cli.mjs` require Node.js 22+ and
no third-party packages. In a shell with the same secret environment variable:

```sh
node tools/rcon/cli.mjs command status
node tools/rcon/cli.mjs request GET /api/dashboard
node tools/rcon/cli.mjs discover
node tools/rcon/cli.mjs logs
```

Warden's `enabled` may remain `false`. The shared admin backend still runs, without
binding the Warden HTTP port. RCON uses TCP, separate from the game's UDP port and
resource HTTP downloads. An RCON connection does not occupy a player slot.

## Remote hosting and TLS

Prefer loopback plus an SSH tunnel:

```sh
ssh -N -L 11782:127.0.0.1:11782 operator@your-server
```

For a direct remote listener configure `bindAddress` and `tlsCertificateFile`
(PFX/PKCS#12 with a private key). Relative certificate paths resolve against the
directory of `server.jsonc`; put its password in the environment variable named
by `tlsCertificatePasswordEnvironmentVariable`. TLS 1.2 and 1.3 are supported.
Clients must validate the hostname and certificate chain; use a trusted CA or
install your private CA. Restrict the TCP port in the firewall to dashboard hosts.

```json
"rcon": {
  "enabled": true,
  "bindAddress": "0.0.0.0",
  "port": 11782,
  "tlsCertificateFile": "private/rcon.pfx",
  "tlsCertificatePasswordEnvironmentVariable": "OP77_RCON_CERT_PASSWORD",
  "permissions": ["dashboard.view", "players.view", "console.view"]
}
```

Plaintext on a non-loopback bind is refused unless `allowInsecureRemote:true` is
explicitly set. That escape hatch is for an isolated network or trusted encrypted
tunnel, **not** the public Internet: without TLS the password and admin traffic
are readable in transit. It does not disable authentication or operation checks.

## Configuration reference

All fields are under `rcon`. Changes apply at the next server start; Warden
configuration/mod edits preserve this section.

| Field | Default | Meaning / allowed range |
| --- | --- | --- |
| `enabled` | `false` | Enable the TCP listener. |
| `bindAddress` | `127.0.0.1` | IPv4/IPv6 literal, not a DNS name. |
| `port` | `11782` | TCP port, 1–65535. |
| `passwordEnvironmentVariable` | `OP77_RCON_PASSWORD` | Environment variable containing the service password (16–1024 characters). No literal-password config field. |
| `allowWardenAccounts` | `false` | Also accept existing Warden operator usernames/passwords and their roles. |
| `permissions` | `["*"]` | Service-account permissions, at most 128 names. An empty array grants no operations. |
| `allowInsecureRemote` | `false` | Explicitly permit plaintext non-loopback TCP; use only in a trusted network. |
| `tlsCertificateFile` | `null` | PFX file with private key; enables TLS from the first byte of the connection. |
| `tlsCertificatePasswordEnvironmentVariable` | `OP77_RCON_CERT_PASSWORD` | Environment variable containing the PFX password; may be absent for unencrypted PFX. |
| `maxConnections` | `32` | Concurrent accepted sockets, including unauthenticated ones; 1–256. |
| `maxConnectionsPerIp` | `8` | Per-source-IP connections; 1–`maxConnections`. |
| `maxFrameBytes` | `1048576` | Incoming authenticated JSON payload cap; 65536–4194304 bytes. |
| `maxInFlightRequests` | `8` | Concurrent `request`/`command` calls per socket, including log streams; 1–32. |
| `maxRequestsPerSecond` | `30` | Incoming operations per socket/second, including upload chunks and pings; 1–1000. |
| `authenticationTimeoutSeconds` | `10` | TLS handshake and authentication deadline; 1–60. |
| `requestTimeoutSeconds` | `60` | Cooperative deadline for normal operations; 1–600. Log streams use session lifetime instead. |
| `idleTimeoutSeconds` | `600` | Deadline for the next complete client frame; 10–86400. Send periodic pings even when receiving logs. |
| `sessionLifetimeSeconds` | `3600` | Absolute authenticated-session lifetime, including reconnects; 10–86400. |
| `maxUploadBytes` | `67108864` | One staged upload per connection; 1–1073741824 bytes. Endpoint-specific body caps still apply. |

The generic startup override system works unchanged:

```sh
Open77.Server --rcon.enabled=true --rcon.port=12782 --rcon.permissions='["dashboard.view","players.view"]'
```

For containers/hosters use `OP77_CONFIG__RCON__ENABLED=true`,
`OP77_CONFIG__RCON__PORT=12782`, etc. `OP77_RCON_PASSWORD` is the **secret itself**,
not a JSON override. CLI overrides take precedence over configuration environment
overrides, which take precedence over the file. `--check-config` validates field
types, ranges and transport policy without binding anything; availability of the
secret, operator accounts, certificate/private key and port is checked at startup.

## Identities, permissions and audit

Omit `username` in `auth` to use the service identity `$service` and `rcon.permissions`.
For per-operator attribution set `allowWardenAccounts:true`, and send the existing
Warden `username` and password. These are **server-local Warden accounts**, not
Open77 website accounts, game ACL identities or master API keys. Named accounts
use their Warden role, not the service permission list. A service password may be
omitted only when named accounts are enabled and an operator already exists.

Roles and permissions are checked on every call. Deleting/recreating an account
does not preserve its existing connection. Role/permission changes close active
sessions within one second; queued game-loop work rechecks authority immediately
before execution. Reauthenticate after a role change. Password/config rotation
for the shared service account requires a server restart.

Audit entries use `rcon:<username>` (or `rcon:$service`), and authentication
success/failure is recorded without the password or session token. The audit
store is shared with Warden: `.open77/warden/audit.jsonl` and `GET /api/audit`.
Commands and normal administrative details remain auditable; never include secrets
in console command text. The setup/reset PIN is not exposed through RCON logs.

Five failed password attempts from an IP trigger a five-minute authentication
cooldown. Failed-auth state and retained sessions are bounded to 4096 entries.
Excess connections close before authentication. Slow readers have a 15-second
write deadline so they cannot retain a connection indefinitely.

`*`, `console.execute`, `resources.upload`, `users.manage` and Workshop mutation
permissions are powerful. Treat their holders as server administrators, not
untrusted players. Use dedicated least-privilege roles for each dashboard.

## Dashboard architecture

Connect from your dashboard's **backend**, not browser JavaScript: browsers do not
offer raw TCP sockets. Keep credentials, certificates and session tokens there.
Protect your own routes with authentication, authorization, CSRF protection and a
small action allowlist. Never forward arbitrary browser requests to an owner-level
RCON connection. Render player names, logs and resource output as text, not HTML.

```js
import { RconClient } from './tools/rcon/client.mjs';

const rcon = await RconClient.connect({
  host: '127.0.0.1', port: 11782,
  password: process.env.OP77_RCON_PASSWORD,
});
try {
  console.log(await rcon.json('GET', '/api/dashboard'));
  console.log(await rcon.json('GET', '/api/players'));
  console.log(await rcon.json('POST', '/api/announce', { reason: 'Restart in 5 minutes.' }));
} finally { rcon.close(); }
```

The helper supports TLS (`tls:{ca,servername}`), discovery, structured requests,
raw streaming downloads, SHA-256 uploads, log subscriptions, cancellation,
request pacing and heartbeats. See its README for all helpers. It deliberately
does not reconnect or replay mutations automatically.

## Protocol v1

Each frame is a 4-byte **unsigned big-endian** payload byte count followed by one
UTF-8 JSON object. The prefix is not included in the length. No terminator, NUL,
newline or BOM is appended. TCP can split a frame anywhere or combine several
frames in one read; buffer/reassemble by length, never by socket-read boundaries.
Lengths below 2, excess sizes, invalid JSON, nesting over 32 levels and duplicate
JSON fields close the connection. Before auth the payload cap is 16384 bytes.

The server first sends:

```json
{"id":0,"type":"hello","protocol":"open77-rcon","version":1,"maxFrameBytes":1048576,"maxInFlightRequests":8,"maxUploadBytes":67108864,"maxRequestsPerSecond":30,"idleTimeoutSeconds":600}
```

Client IDs are positive integers up to `9007199254740991`, **strictly increasing
within a connection**. IDs reset after reconnect. Responses may interleave across
IDs, but keep their order within each ID. All field names and operation names are
case-sensitive. IDs identify replies, not globally durable idempotency keys.

Authenticate before any operation:

```json
{"id":1,"op":"auth","version":1,"password":"<secret from your secret store>"}
```

Optional fields are `username` and `sessionToken`. Successful auth returns:

```json
{"id":1,"type":"result","ok":true,"username":"$service","permissions":["*"],"sessionToken":"rcon:<opaque token>","expiresAtUtc":"2026-09-23T18:00:00+00:00"}
```

To resume Workshop plan/job/export ownership, reconnect with **both credentials
and the token**, as the same identity. The token does not replace authentication,
extend its original expiry or resume an unfinished command. New uploads, request
IDs and log subscriptions are connection-local. Tokens are in-memory, expire at
`expiresAtUtc` and are invalid after server restart. Losing/expiring a token means
obtaining a fresh session and rebuilding its plans; persistent Workshop history
and recovery remain available through their normal endpoints.

### Requests and replies

| Operation | Request fields | Reply |
| --- | --- | --- |
| `ping` | None | `result` with `ok:true`. |
| `discover` | None | `result` with `protocol:1`, `operations:[{method,path},…]`. |
| `command` | `command` string | Same streamed result as `POST /api/console/command`. |
| `request` | `method`, `path`; optional `body` JSON **or** `uploadId`, `contentType` | `response`, zero or more `data`, then `end`. |
| `cancel` | `requestId` | `result` with `cancelled` and target `requestId`. |
| `upload.begin` | `bytes`, hexadecimal SHA-256 `sha256` | `result` with `uploadId`. |
| `upload.chunk` | `uploadId`, current byte `offset`, base64 `data` | `result` with cumulative `bytes`. |
| `upload.finish` | `uploadId` | `result` with `ready:true` after length/hash verification. |
| `upload.abort` | `uploadId` | `result` with `ok:true`. |

`request` methods: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`. Paths are relative
`/api/...` with an optional query string, not external URLs. `contentType` defaults
to `application/json`; staged binary requests use `application/octet-stream`.
No arbitrary browser cookie, authorization or origin headers are accepted.

```json
{"id":2,"op":"request","method":"GET","path":"/api/players"}
{"id":3,"op":"command","command":"status"}
{"id":4,"op":"request","method":"POST","path":"/api/restart","body":{"delaySeconds":60,"reason":"Maintenance"}}
```

Each administrative response has this envelope:

```json
{"id":2,"type":"response","status":200,"contentType":"application/json; charset=utf-8","headers":{}}
{"id":2,"type":"data","data":"W10="}
{"id":2,"type":"end","complete":true,"bytes":2,"error":null}
```

Here `W10=` decodes to `[]`. Decode each base64 chunk, concatenate **bytes**, then
decode UTF-8/JSON; characters can span chunks. Data chunks contain at most 32768
decoded bytes. `bytes` is the total decoded size. Downloads are streamed with TCP
backpressure. Selected headers (`Content-Disposition`, `Content-Range`, `ETag`,
`Retry-After`) are preserved; no browser session cookie is forwarded.

`complete:true` means the transport operation finished, **not that it succeeded**.
Check `status` and the JSON body's `ok`, `error` or job/ticket state. A 202 is an
accepted asynchronous job; poll it. A 200 with `ok:false` is an application refusal.
`end` with `complete:false` means interrupted processing, even after a 200 header.

Transport/validation errors can instead return:

```json
{"id":5,"type":"error","error":{"code":"busy","message":"The session already has the maximum number of active requests."}}
```

Codes include `authentication_required`, `authentication_failed`,
`unsupported_version`, `session_unavailable`, `session_revoked`,
`already_authenticated`, `unknown_operation`, `invalid_request`, `busy`,
`rate_limited`, `cancelled_or_timed_out`, `payload_too_large`, `operation_failed`.
Malformed envelopes/lengths, expired authentication/session deadlines and exhausted
connection limits may close without an error frame. Do not treat EOF as success.
Rate-limit errors close the connection: reconnect with slower pacing, not a tight
retry loop. The bundled helper paces requests from the advertised limit.

### Cancellation, streams and uploads

`GET /api/console/stream?after=<last-seq>` returns raw UTF-8 SSE inside `data`
frames (`data: {log JSON}\n\n`). Keep parsing across chunks. `cancel` ends that
request; other commands continue. The recent tail and live feed are bounded;
sequence gaps may occur under load. Periodic pings are required on a read-only
subscription to satisfy the session idle timer.

Each connection may stage one upload at a time. Declare its byte length and
SHA-256, send ordered base64 chunks at the exact next offset, then finish. The
verified `uploadId` can replace a request's JSON body once. It cannot refer to an
arbitrary server path or another session's upload. Abort/disconnect removes the
temporary file. The transport's upload cap does not bypass endpoint limits:
ordinary admin bodies are capped at 4 MiB, required-mod archive bodies at 64 MiB.

Cancellation prevents queued game-loop work from beginning, but cannot roll back
an operation already committed. An accepted Workshop job has its own lifetime and
explicit `/cancel` operation: cancelling the **request** or losing the connection
does not cancel the **job**. Use the session token to reconnect and inspect it.
After any timeout/disconnect, query state before retrying a mutation. Never replay
kick, grant, install, publish or reset automatically.

## Administrative API surface

`discover` enumerates the actual registered operations of the running build,
including route templates such as `{id:guid}`. Replace placeholders with values
and URL-encode each path segment. Discovery shows availability, not permission
grants or ready state. An unavailable subsystem answers explicitly (e.g. 503).
Payloads/results are Warden's API contracts, not console-output scraping.

| Area | Representative routes | Required permissions |
| --- | --- | --- |
| Dashboard | `GET /api/dashboard` | `dashboard.view` |
| Players | `GET /api/players`; `POST /api/players/{id}/kick`, `/ban`, `/warn`, `/heal`, `/freeze`, `/unfreeze`, `/teleport`, `/bring` | `players.view` and corresponding `players.*` action |
| Announce/restart | `POST /api/announce`, `POST`/`DELETE /api/restart` | `announce.send`, `restart.schedule` |
| Server reset | `POST /api/reset/arm`, `POST /api/reset` | `server.reset`, plus real-console PIN and typed-name confirmation |
| Resources | `GET /api/resources`; `POST /api/resources/{name}/{action}`, `/validate`, `/files` | `resources.view`, `resources.control`, `resources.upload` |
| Console/logs | `POST /api/console/command`; `GET /api/console/log`, `/api/console/stream` | `console.execute`, `console.view` |
| In-game ACL | `/api/acl`, `/api/acl/roles`, `/api/acl/identities`, reload/grant/revoke routes | `acl.view`, `acl.edit`; grant authority still constrained |
| Whitelist/bans | `/api/access`, `/api/access/whitelist`, `/api/access/bans/{userId}` | `access.view`, `access.edit` |
| Tunables | `/api/tunables`, `/api/tunables/{resource}/keys/{key}`, `/api/tunables/{resource}/promote` | `tunables.view`, `tunables.edit` |
| Configuration/branding | `GET`/`POST /api/config`, `GET /api/config/icon`, `/api/config/banner` | `config.view`, `config.edit` |
| Required mods | `/api/mods`, `/api/mods/inspect`, `/api/mods/{id}`, review requests | `mods.manage` |
| Operator accounts/roles | `/api/users`, `/api/users/{name}/role`, `/api/roles` | `users.manage` |
| Audit | `GET /api/audit` | `audit.view` |
| Workshop | `/api/hub/*`: catalog, plans, jobs, install/update/remove/rollback, retention, exports, creator linking, publishing | `hub.view`, `hub.manage`, `hub.publish` as applicable |
| Performance | `/api/performance/*`: state, captures, capture control and binary exports | `performance.view`, `performance.control` |

Examples (bodies are passed as `body` in `request`):

```js
await rcon.json('POST', '/api/players/7/kick', { reason: 'AFK' });
await rcon.json('POST', '/api/players/7/warn', { reason: 'Please follow the rules.' });
await rcon.json('POST', '/api/players/7/freeze', {});
await rcon.json('POST', '/api/players/7/unfreeze', {});
await rcon.json('POST', '/api/resources/my_resource/restart', {});
await rcon.json('POST', '/api/access/whitelist', { enabled: true });
await rcon.json('POST', '/api/config', { name: 'My server', maximumPlayers: 32 });
await rcon.json('POST', '/api/tunables/my_resource/keys/speed', { value: 5 });
await rcon.json('POST', '/api/roles', { name: 'observer', permissions: ['players.view', 'dashboard.view'] });
```

Configuration changes have the same limited editable fields and restart-required
indicators as Warden; RCON is not arbitrary shell access or a raw JSON file writer.
Likewise, restarting a stopped server process still needs a supervisor/systemd or
your hosting control plane: a process cannot receive TCP commands while stopped.
The game loop remains authoritative for all live state changes.

Browser login/logout/session/setup, provisioning, HTML and `/health` are not
RCON operations. Operator provisioning happens through Warden setup or a trusted
service account managing `/api/users`; RCON auth is its own protocol exchange.

See also [Warden player actions](warden-players.md),
[Warden performance](warden-performance.md), [identity and ACL](server-acl.md),
[connection control](connection-control.md), [server mods](server-mods.md), and
[server resources](server-resources.md). The definitive endpoint registrations
and request DTOs are in `server/src/Open77.Server/Warden/WardenHost*.cs`;
`discover` should be used to check the exact server build before enabling a panel
feature.

## Diagnostics and operating limits

At startup look for `RCON TCP listening on ... (TLS=...; authentication required)`.
No listener means disabled configuration or a startup failure. A refused connection
can mean the wrong TCP port, loopback binding, firewall, capacity or auth cooldown.
Do not confuse the RCON port with UDP 11778 or Warden HTTP.

For TLS failures check the PFX private key, certificate validity/name/chain and
whether both sides enabled TLS; there is no STARTTLS negotiation. For refused
operations inspect the structured permission/error response, server logs and
Warden audit. Debug logging records connection error types without echoing wire
payloads or credentials. Keep those diagnostics private.

Use separate connections for large exports/live logs and latency-sensitive
commands. `busy` means per-session in-flight capacity, not necessarily a broken
server. Raising the transport caps does not disable the shared game-loop timeout,
Workshop validation or endpoint-specific size limits.
