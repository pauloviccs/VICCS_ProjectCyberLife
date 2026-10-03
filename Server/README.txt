OPEN//77 dedicated server — ready-to-configure Freeroam distribution
==================================================================

Includes the matching server runtime, .NET/ASP.NET runtime, native transport,
production platform verifier, Freeroam (Race/PvP/animation menu), wardrobe,
admin, chat, voice, weather, elevators and all declared system dependencies.
The exact versions and per-file SHA-256 values are in package-manifest.json.
Players need Cyberpunk 2077 and the clientVersion listed in package-manifest.json.
Client and server network protocols must match; update both sides together when
the protocol changes. A newer client cannot join an older incompatible server.
The server host does NOT need the game or a separate .NET installation.

FIRST START — extract into a new directory
  Windows x64: double-click Start.cmd (or run Open77.Server.exe).
  Linux x64:   ./start.sh (or ./Open77.Server).
  Linux still requires the normal OS runtime libraries (ICU, OpenSSL 3,
  libstdc++, zlib); supported Debian/Ubuntu distributions provide these.

No server.jsonc is pre-created: the first launch starts Warden onboarding on
every interface (http://0.0.0.0:11780, or 11781/11782 if taken) and prints the
addresses you can open plus a one-time setup PIN. From your own machine open
http://<server-ip>:11780/, enter the PIN, choose Freeroam, set your name,
license key, public address/ports, then create the Warden admin. The same
process continues into the game server after setup. Open port 11780/TCP in your
firewall or security group first if the host has one.

The PIN is the only protection during setup and it locks after a few wrong
guesses. To keep setup local instead, start with
  ./start.sh --setup-listen http://127.0.0.1:11780   (or set OP77_WARDEN_SETUP_LISTEN)
and use an SSH tunnel: ssh -L 11780:127.0.0.1:11780 user@your-vps

Warden itself is plain HTTP. The "Warden panel URL" field in setup decides
where it listens afterwards (0.0.0.0 = reachable from the internet). For daily
use put a TLS reverse proxy (Caddy, nginx) in front or keep it on 127.0.0.1
behind an SSH tunnel.

WORKSHOP (community resources in Warden)
  Browsing the Workshop works as soon as the server is registered with the master.
  To INSTALL creations from Warden, add to server.jsonc and restart:
    "warden": { "enabled": true, "hubFileGatewayOrigin": "https://files.open2077.net" }
  Guide: https://open2077.net/docs/community-hub-warden

NETWORK
  Default game: 11778/UDP; resource download: 11779/TCP (game port + 1).
  Forward/open both. The resource URL must be reachable by players, not localhost.
  HTTPS is recommended: put a TLS reverse proxy in front of the resource port
  and enter its base URL in onboarding. Without TLS, explicitly opt in to HTTP;
  signatures/hashes still protect package integrity, but transport is unencrypted.
  Do not point your resource URL at Open77's CDN: your server serves its own set.
  A platform license from https://open2077.net/account/keys is required for listing.

HOSTING AUTOMATION AND LOG LEVELS
  Every server.jsonc field supports --set section.field=value or --section.field value.
  Provider example (use your autoinstaller's actual public IP):
    ./start.sh --no-setup --config server.jsonc --public-ip 194.231.216.11 --port 11778 --max-players 32 --log-level info
  --public-ip fills the advertised game/download addresses and enables downloads
  on 0.0.0.0 at the configured resource listener port (11779 by default).
  Specific field overrides win, so HTTPS reverse-proxy URLs can be retained.
  OP77_PUBLIC_IP and OP77_CONFIG__SECTION__FIELD provide the same environment controls.
  Priority: arguments > environment > JSONC file > defaults. No file is rewritten.
  --log-level accepts trace, debug, info, warn, error (minimum severity).
  Legacy --verbose means trace when no explicit logging.level is configured.
  Add --check-config to validate and exit without listeners, setup or state writes.
  Keep credentials in OP77_LICENSE_KEY / OP77_DATABASE_CONNECTION, not command arguments.
  See docs/server-configuration.md for complete examples, NAT, IPv6 and precedence.

READY TO PLAY, OPTIONAL PERSISTENCE
  Freeroam is the only selected gamemode; Race/PvP run inside it.
  No separate resource downloads or builds are needed. Use /freeroam, /pvp, /anim.
  Race starts without saved circuits. An operator creates routes with /race.editor.
  MySQL is optional for initial play; durable characters/careers need your own
  database configured through the server bridge. Never share its connection string.
  The admin account for Warden is not automatically a game-player ACL grant.

UPDATING AN EXISTING SERVER
  This is a fresh-install archive, not an automatic migration/overwrite script.
  Back up server.jsonc, acl.jsonc, .open77 identities/signing keys and resource
  data/ plus your database. Preserve your settings, credentials and saved courses.
  Stop the server before replacing binaries. Do not overwrite private state with
  another server's identity or replace resources during active sessions.

No credentials, player records or recorded runtime data are bundled.
Documentation: https://open2077.net/docs/host-a-server
Gamemode source: https://github.com/Open2077/freeroam
License and notices: LICENSE and licenses/.

AI AGENTS (tools/mcp)
  tools/mcp is the Open77 Devkit MCP: it gives Claude Code, Codex, Cursor or
  VS Code every Lua native, permission, event and game-data name of THIS build,
  plus a validator for your resources. With Node 20+ installed, run
    tools/mcp/install.ps1   (Windows)   or   tools/mcp/install.sh   (Linux)
  once; it registers the MCP in the agents found on the machine. Docs:
  https://open2077.net/docs/agents
