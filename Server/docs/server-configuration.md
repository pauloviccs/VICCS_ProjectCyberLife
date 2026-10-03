# Dedicated server configuration

For dashboard and hosting integrations, see [authenticated TCP RCON](../wiki/rcon.md):
configuration, TLS, Warden permissions, structured commands, live logs and transfers.

Open77 dedicated servers use a validated JSONC configuration file. Public servers can enroll with
the Open77 master directory, publish their metadata, and maintain a short-lived catalog lease
without placing directory logic in the gameplay data path.

## Configuration files

| File | Purpose |
|---|---|
| `server/server.jsonc` | Default operator configuration when launched from `server/`. |
| `server/server.example.jsonc` | Versioned configuration template. |
| `server/config/server.schema.json` | JSON Schema for validation and editor completion. |
| `server/tunables.json` | Gameplay settings retuned from Warden. Written by the server, never by hand. |

The parser accepts comments and trailing commas, rejects unknown properties, and requires the
current `schemaVersion` of `1`.

Start from the example instead of editing generated runtime files:

```powershell
Copy-Item .\server.example.jsonc .\server.jsonc
```

`tunables.json` sits deliberately **outside** `server.jsonc`. It holds only the values a resource
declared as tunable and an operator moved from the Warden Tuning tab, keyed by resource, and it is
rewritten every time one changes — so keeping it in its own file means a tuning write can never
touch `identity`, `network` or `startup.commands`. Within the file the writer edits a DOM read back
from disk and replaces exactly one resource's section, leaving every other section and every
unrecognised property byte-for-byte; a file it cannot parse is left untouched rather than
overwritten. Delete it to put every gamemode back on its declared defaults. See
[Lua resources](lua-resources.md#operator-tunable-settings) for the declaration format.

## Hosting-provider startup

Every field in `server.jsonc` can be overridden at process startup. Download settings
are nested under **`resources.download`**, not a top-level `download` section.

```sh
./Open77.Server --no-setup --config server.jsonc \
  --set network.port=11778 \
  --set network.publicEndpoint=194.231.216.11:11778 \
  --set network.maximumPlayers=32 \
  --set resources.download.enabled=true \
  --set resources.download.listenUrl=http://0.0.0.0:11779/ \
  --set resources.download.publicBaseUrl=http://194.231.216.11:11779/ \
  --verbose
```

For an autoinstaller, the shorter equivalent is:

```sh
./Open77.Server --no-setup --config server.jsonc \
  --public-ip 194.231.216.11 --port 11778 --max-players 32 --verbose
```

`--public-ip` uses the IP **provided by the hosting platform**. It fills
`network.publicEndpoint` using the final game port, enables resource downloads,
binds them to `0.0.0.0` using the configured download-listener port (default `11779`),
and fills the public HTTP download URL. This also replaces loopback values in older
templates. It accepts an IPv4 or IPv6 literal without a port; IPv6 advertised URLs
are bracketed automatically. For an IPv6 download listener, explicitly use
`--set resources.download.listenUrl=http://[::]:11779/`.

Specific startup overrides of these fields always take priority over `--public-ip`,
regardless of argument order. This lets a provider retain an HTTPS reverse proxy,
a loopback-only internal listener, or a different external NAT port. A whole section
supplied as JSON also counts as an explicit override of its children. No third-party
IP-discovery service is contacted, no interface is guessed, and no firewall/NAT rule
is changed. Open the game **UDP** port and download **TCP** port in the VPS firewall
and publish both in container networking. The download listener is not the Warden
admin listener or the resource HTTP-handler listener; their settings are unchanged.

### Generic overrides and precedence

Priority is **built-in defaults < JSONC file < environment < command line**. Repeated
command-line fields use the last value, including when mixing aliases and generic
options. Values are overlaid **before semantic validation**, so a template with an
unset public endpoint can be completed by the host. JSON syntax and field types in
the file must still be valid. Existing aliases (`--name`, `--port`, `--max-players`,
`--public-endpoint`, `--visibility`, `--tick-rate`, etc.) continue to work.

```sh
./Open77.Server --no-setup --config server.jsonc \
  --network.maximumPlayers 64 \
  --set 'identity.tags=["roleplay","english"]' \
  --set 'resources.load=["open77_*","freeroam","!open77_debug"]' \
  --set 'convars.server_region=eu' \
  --set 'startup.commands=["weather clear"]'
```

Both `--set section.field=value` and `--section.field value` work, as do the inline
forms `--set=section.field=value` and `--section.field=value`. Configuration field
names are case-insensitive. Strings are plain text (quote them for your shell when
they contain spaces); arrays and objects use JSON. Booleans use `true`/`false`.
`null` clears a nullable value; JSON `"null"` is a literal string. An array can be
replaced wholesale or an existing item overridden with a numeric dotted index,
for example `--set identity.tags.0=roleplay`. Unknown fields, invalid indices, types
and out-of-range values fail with exit code `2` and a field-specific diagnostic.

For Docker, systemd and hosting panels, the same fields can be supplied as environment
variables. Use double underscores instead of dots:

```sh
export OP77_PUBLIC_IP=194.231.216.11
export OP77_CONFIG__NETWORK__PORT=11778
export OP77_CONFIG__NETWORK__MAXIMUMPLAYERS=32
export OP77_CONFIG__RESOURCES__DOWNLOAD__LISTENURL=http://0.0.0.0:11779/
export OP77_CONFIG__LOGGING__VERBOSE=true
./Open77.Server --no-setup --config server.jsonc
```

`OP77_PUBLIC_IP` is the environment fallback for `--public-ip`. Specific
`OP77_CONFIG__...` fields still override this convenience's generated addresses.
The licence and database connection retain their existing secret environment
variables (`OP77_LICENSE_KEY`, `OP77_DATABASE_CONNECTION`). Prefer those over
arguments containing secrets, which other local processes or panel logs may expose.

Overrides are **in-memory only**: `server.jsonc` and its comments are not rewritten.
Keep the startup arguments/environment in the hosting panel or service definition
so they survive restarts. Warden edits the underlying file; a startup override of
the same field continues to win on the next boot. `--no-setup` skips the first-run
wizard for automation; it does not install a gamemode, create a licence or disable
authentication. Supply your normal provisioned configuration/resource bundle.

### Log levels, verbose and validation-only mode

```jsonc
"logging": { "level": "info" }
```

Set the minimum severity with `--log-level debug`, `--set logging.level=debug`, or
`OP77_CONFIG__LOGGING__LEVEL=debug`. The five levels are ordered **trace < debug <
info < warn < error**: `warn` keeps warnings and errors; `debug` keeps everything
except trace. Filtering applies before terminal output, the retained ring buffer
and Warden's live console. Lua `print`/info logs are information-level and are
therefore hidden at `warn` and `error`. Startup failures and mandatory setup
instructions are still reported independently of this filter.

Legacy `--verbose`/`logging.verbose=true` selects `trace`; `--no-verbose` (or
`--verbose=false`) selects `info`. An explicit non-null **`logging.level` wins over
verbose**, even if the verbose flag appears later. Set `logging.level=null` to use
the legacy switch again. The default is `info` when neither is specified.

Debug/trace also includes runtime/simulation details and every resource download
request, including successful chunks. These additional diagnostics do not dump the configuration, credentials,
query strings or request bodies. Third-party/resource logs retain their own behavior.
GNS's low-level native handshake trace remains a separate advanced
`OP77_GNS_DEBUG` option. Verbose can produce substantial I/O on a busy server.

Append `--check-config` to the **same** production startup command to validate the
effective configuration and print a safe network summary without opening the setup
wizard, binding ports, contacting the Master, running resources or writing state:

```sh
./Open77.Server --config server.jsonc --public-ip 194.231.216.11 --verbose --check-config
```

Exit `0` means the configuration is valid; exit `2` means an error. This does not
test firewall reachability, database credentials or installed resource contents.
`--help` also exits without first-run setup. The same configuration-file selection
is used by runtime, onboarding, Warden and Hub recovery, including `--config=PATH`.

## Warden Hub configuration

The Hub catalog uses the configured master origin. Installing packages also requires
`warden.hubFileGatewayOrigin`, the trusted file-gateway origin supplied by the Hub operator.
It accepts HTTPS or an explicit loopback IP with HTTP for local testing, with no path,
credentials, query or fragment. For an isolated local stack, the value can be
`http://127.0.0.1:18091`. Omitting it leaves browsing available and installation disabled.

Operators need `hub.view` to browse and `hub.manage` to plan/install. Review the exact
release, permissions, file changes, load rules and dependent resource restarts before
confirming installation. Plans expire after ten minutes and are checked again against
the current server before files change. Updating means reviewing a new release explicitly;
there are no automatic updates. Local edits can block an update; declared configuration
files and untracked user files are preserved. A cancellation request remains pending while
the installer restores an interrupted activation.

Hub ownership, private staging and recovery artifacts live under `.open77/hub`, outside
the resource root. Keep staging, backups and resource targets on the same mounted
filesystem. Back up this directory together with the resource root and server configuration;
private job artifacts include copies of configuration and must not be shared publicly.
On startup, unfinished installations are reconciled before resources or preloads are
loaded. If recovery detects operator edits or inconsistent artifacts, startup stops so
those files remain available for investigation. Do not delete the journal to bypass it.

Current implementation limits: preload packages still require the unfinished restart
workflow; explicit rollback of a completed install, uninstall, persistent job history and
creator publishing are not yet available. Recovering package files cannot undo external
database writes or other effects produced by Lua. Linux directory entries are flushed
during swaps; Windows directory-flush and whole-stack power-loss guarantees remain unverified.

## Public identity

The `identity` section controls catalog metadata:

| Field | Description | Limit |
|---|---|---|
| `name` | Displayed server name | 96 UTF-8 bytes |
| `description` | Public summary | 512 UTF-8 bytes |
| `locale` | Primary BCP 47 locale | For example `en-US` |
| `tags` | Catalog filters | 16 unique slugs, 24 characters each |
| `website` | Optional community URL | Absolute HTTP(S) URL |
| `discord` | Optional community URL | Absolute HTTP(S) URL |
| `icon` | Local PNG path | 32-512 px, at most 256 KiB |
| `visibility` | Listing mode | `public`, `unlisted`, or `private` |

Only `public` servers can publish to the catalog. `unlisted` and `private` remain available for
direct-connect and controlled development workflows.

Icon paths are confined to the configuration directory. Absolute paths, traversal, symbolic links,
and reparse points are rejected. The server validates PNG dimensions and hashes the file before
publication.

## Network and simulation

```jsonc
"network": {
  "port": 11778,
  "publicEndpoint": "play.example.net:11778",
  "maximumPlayers": 64
},
"simulation": {
  "tickRate": 30,
  "snapshotRate": 20,
  "expectedGameBuild": 23100,
  "helloTimeoutSeconds": 10
}
```

`network.port` is the UDP bind port. `publicEndpoint` is the address advertised to players and may
differ when the server is behind NAT, a container boundary, or a tunnel.

`maximumPlayers` counts authenticated sessions only. Pending sockets are excluded. The simulation
validator requires `snapshotRate <= tickRate` and bounds all timing values.

## Replication rollback switches

The optional `replication` section takes individual protocol 38 mechanisms back to the behaviour
they replaced, without a rebuild. Leave it out to run the shipped behaviour; set a key only to roll
one mechanism back while a problem is investigated. The values are read once at startup, so a
change needs a restart (Warden edits preserve the section).

```jsonc
"replication": {
  "contactSteward": true,
  "contactEpisodes": true,
  "trafficLanes": true,
  "hitRewindStrict": false,
  "timedMotionWindowMs": 20,
  "timedVehicleValidationTicks": 6,
  "timedStarvationShareMs": 50
}
```

| Key | Default | Range | Rollback value and effect |
|---|---|---|---|
| `contactSteward` | `true` | boolean | `false`: an unattended car about to be struck is no longer simulated by the approaching driver; it stays at owner 0 and moves on the striker's screen only. |
| `contactEpisodes` | `true` | boolean | `false`: both owners' reports of one car/car crash are two events again, and the counterpart is delivered at once. |
| `trafficLanes` | `true` | boolean | `false`: connections opened afterwards keep the native single GNS lane instead of ordered / timed motion / voice lanes. |
| `hitRewindStrict` | `false` | boolean | `true` makes the check *stricter*: a player hit must match the victim's rewound path, and the newest pose no longer rescues it. |
| `timedMotionWindowMs` | `20` | 5 to 100 | `15`: native send-queue allowance of a timed motion batch before the near-lane phase. Above the 40 ms reliable window, motion can delay reliable traffic by the difference. |
| `timedVehicleValidationTicks` | `6` | 1 to 30 | `1`: vehicle scopes are revalidated every tick instead of every sixth (5 Hz at the default 30 Hz tick). |
| `timedStarvationShareMs` | `50` | 0, or 10 to 1000 | `0`: the strict "reliable always first" rule; otherwise one timed batch may pass after this long without a timed admission while reliable traffic holds the link. |

Precedence is per key: an explicit `replication.*` value wins, whether it comes from the file,
`--set replication.<key>=...` or `OP77_CONFIG__REPLICATION__<KEY>`. A key that is absent or
`null` falls back to the legacy environment variable of the three switches that had one —
`OP77_CONTACT_STEWARD`, `OP77_CONTACT_EPISODES` and `OP77_GNS_TRAFFIC_LANES`, where exactly `0`
turns the switch off and any other value leaves it on — and then to the default. An out-of-range
value fails the configuration load with the key and the allowed range in the message.

When anything differs from the defaults the server logs one startup line, for example
`Replication switches (non-default): contactSteward=false, timedMotionWindowMs=15.` The same line
reports `serverGc=true (DOTNET_gcServer)` when the .NET server garbage collector is on. Server GC
stays a runtime setting of the .NET host, not a configuration key: it must be known before the
process starts, so set `DOTNET_gcServer=1` in the service or container environment (opt-in; it
cuts GC pauses under heavy load at the cost of memory).

## Access control

```jsonc
"accessControl": {
  "file": "acl.jsonc"
}
```

The ACL path is relative to the configuration directory. It contains public identity principals and
command permissions, never private client keys. Keep operator-specific ACL files out of source
control.

See [authentication](authentication.md) for identity export and command matching.

## Resource hosting

```jsonc
"resources": {
  "enabled": true,
  "root": "../resources",
  "load": [
    "open77_*",
    "freeroam",
    "open-voice",
    "!open77_debug",
    "../shared-resources/**"
  ],
  "autoStart": true,
  "watchIntervalMilliseconds": 0, // 0 = no automatic rescan (default); `refresh` / `ensure <resource>` at the console
  "download": {
    "enabled": true,
    "listenUrl": "http://0.0.0.0:11779",
    "publicBaseUrl": "https://cdn.example.net/",
    "cacheDirectory": ".open77/resource-cache",
    "signingKeyFile": ".open77/resource-signing-key.json",
    "chunkSizeBytes": 1048576
  }
}
```

`load` is the server's resource set. Rules are evaluated in order: a normal rule adds matching
resource directories and a rule beginning with `!` removes matches selected earlier. A bare name
or glob is relative to `root`; relative subpaths and absolute paths are accepted too. `*` and `?`
match inside one directory level, while a complete `**` segment traverses any number of levels.
Every selected directory must contain `open77.lua`; spelling the final `/open77.lua` is optional.

For compatibility, omitting `load` is exactly the same as `"load": ["*"]`: every immediate
resource directory under `root` is selected. An explicit empty array selects none. The server
re-evaluates wildcard matches on every resource scan, but changing the rules in the configuration
file itself requires a server restart. A selected resource whose manifest dependency is not also
selected fails to start with the missing resource's name instead of silently loading an excluded
directory.

Only selected, running resources are packaged for clients. Consequently, excluding a resource also
removes its client scripts and files from the next published generation. The resource root remains
the default base for relative rules. The cache and signing key are private runtime data. Preserve
the signing key during migration to keep the same resource identity.

The operator-focused [server resources wiki](../wiki/server-resources.md#selecting-which-resources-load)
contains exact-list, wildcard, exclusion, recursive path, absolute Windows path and troubleshooting
examples.

`publicBaseUrl` must use HTTPS outside loopback. Place the download listener behind a reverse proxy
or CDN when exposing it to the Internet.

### Required mods and unsecured mode

`requiredMods` declares what every player must install before joining (see
[Mods your server requires](../wiki/server-mods.md)). Two flags matter operationally:

- `enabled` must be `true` for any selected resource that declares `preload_mod`; the package is
  then served as a hosted required mod named `<resource>-assets`.
- `unsecured` (default `false`) lets the server require executable packages without a verified
  attestation and lets resources preload them. The server logs `UNSECURED MODE` at boot, publishes
  `requiredModsUnsecured` to the master, Warden shows a red chip, and every server list badges the
  world and makes the player confirm the risk before connecting.

## Master directory enrollment

Enable publication only after configuring a reachable public endpoint:

```jsonc
"identity": {
  "name": "Night City Stories",
  "description": "English roleplay server.",
  "locale": "en-GB",
  "tags": ["roleplay", "english"],
  "icon": "branding/server-icon.png",
  "visibility": "public"
},
"masterServer": {
  "enabled": true,
  "url": "https://master.open77.dev/",
  "identityFile": ".open77/master-identity.json",
  "heartbeatIntervalSeconds": 30
}
```

On first launch, the server generates a UUID and 256-bit secret, stores them atomically in the
identity file, and performs idempotent enrollment. Later launches reuse that identity.

The identity file is an operator secret:

- back it up with private server data;
- never commit or publish it;
- do not share it between independently listed servers;
- do not delete it as a method of revocation.

Deleting it creates a new identity but does not revoke the previous one. Use the master admin CLI
for rotation or revocation.

HTTPS is mandatory except for a loopback development master.

## Publication lifecycle

After enrollment, the publisher uses bearer authentication:

| Method | Route | Purpose |
|---|---|---|
| `PUT` | `/api/v1/servers/{serverId}` | Register or replace the active lease. |
| `POST` | `/api/v1/servers/{serverId}/heartbeat` | Update counters, uptime, and sequence. |
| `DELETE` | `/api/v1/servers/{serverId}` | Remove the current session during clean shutdown. |

Each process uses a random `sessionId` and monotonic heartbeat sequence. Deletion includes
`X-Open77-Session-Id`, preventing an old process from removing a newer session with the same server
identity.

### Who is online (`publishPlayerList`)

The heartbeat carries the display names of the players currently connected, so the server's public
page can show *who* is on rather than only how many. It is on by default:

```jsonc
"masterServer": {
  "enabled": true,
  "publishPlayerList": false   // opt out; the page then says nothing about who is on
}
```

- **Names only.** No account id, no device identity, no address, no position. The name published is
  the one every player in the world already reads on the nameplates around them, and joining is
  free — so the list was never private. An identifier would be, which is why none is sent.
- **On by default** because the value of the feature *is* the public page: an opt-in would have
  shipped it dark on every server that already exists.
- **Off is not empty.** With `publishPlayerList: false` the heartbeat sends `players: null` and the
  directory answers `"players": null` — "does not publish". A publishing server with nobody on it
  sends `[]`, which reads as "nobody is here". A page shows those differently.
- Registration deliberately carries no roster (it also carries the icon and banner against the
  master's 512 KiB body limit), so a freshly started or re-registered server publishes no roster
  until its next heartbeat.

Publishing runs in the background and never blocks the server tick. Directory failures are logged
and retried; they do not disconnect players. A missing or expired lease triggers full registration.

## Full server reset (Warden danger zone)

The Warden Config tab offers **Reset server** to owner-level operators (the `server.reset`
panel permission — implied only by the owner's `*`). It returns the server to its first-boot
state: the next start runs the first-time setup wizard again.

**Nothing is deleted.** The reset moves state into one timestamped bundle created beside
`.open77` — `open77.pre-reset-<timestamp>/` — mirroring the original layout:

| Parked into the bundle | Never touched | Kept in place by default |
|---|---|---|
| `server.jsonc`, `tunables.json`, `acl.jsonc`, Warden-written `server-icon.png` / `server-banner.*`, `.open77/warden/` (panel accounts + audit log), `.open77/resource-cache/`, `.open77/identities.json` | **The resource root and everything under it**, `.open77/run/`, `.open77/dev-license.key`, log files, database contents (external MariaDB is never dropped) | `.open77/master-identity.json` and `.open77/resource-signing-key.json` — parked only when "also forget the server's master identity" is ticked (true factory reset: the master sees a brand-new server and every client re-downloads all resources) |

Confirmation takes three factors: an owner-level session, a one-time PIN printed to the
**server's console/journal** (deliberately not to the panel's log stream — the original setup
PIN cannot be reused because it is consumed when the admin account is created), and the
server's exact name typed into the dialog. Every step is audited; the audit entry rides into
the parked bundle.

After a successful reset the server stops with **exit code 11** (distinct from the
scheduled-restart code 10). A supervised relaunch enters the setup wizard — unless the unit
passes `--no-setup`, which makes an unconfigured server fail fast instead of opening the
wizard. **Remove `--no-setup` from the service unit before restarting a reset server**, and
put it back once setup is done if you want fail-fast behaviour in production.

**To restore the previous state:** stop the server, move the contents of
`open77.pre-reset-<timestamp>/` back beside `.open77` (same relative paths), and start it
again.

## Command-line overrides

```text
--config PATH
--name NAME
--description TEXT
--visibility Public|Unlisted|Private
--public-endpoint HOST:PORT
--port PORT
--max-players COUNT
--tick-rate HZ
--snapshot-rate HZ
```

Overrides pass through the same validation as JSONC configuration.

For directory deployment, storage, APIs, and administration, see the
[master server guide](master-server.md). For resource download details, see
[server Lua and resource distribution](server-lua-runtime-and-resource-distribution.md).
