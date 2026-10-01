# Build resources with an AI agent

Use the OPEN//77 Devkit MCP to give a coding assistant access to the Lua API for your server build. It supports API lookup and resource validation, including client/server runtime checks.

It is one package, `@open2077/mcp`, open source at
[github.com/Open2077/open77-devkit](https://github.com/Open2077/open77-devkit).

## Install in one line

From inside your server folder, so the build is detected:

```bash
npx -y @open2077/mcp init
```

That registers the MCP (as `open77-devkit`) in every agent found on the machine (Claude Code, Codex CLI, Cursor,
VS Code, Claude Desktop, Windsurf, Gemini CLI), without overwriting an existing entry that says
something else. Restart the agent, or reconnect its MCP servers, and ask it:
*which OPEN//77 build are you answering for?*

`npx -y @open2077/mcp uninstall` reverses it. Node 20 or newer is the only requirement. The server
archive also ships the package under `tools/mcp` with an install script, so a server box with Node
but no npm access can register it from there.

## Without Node, or from claude.ai

The hosted endpoint serves the documentation tools with nothing installed:

```
https://mcp.open2077.net/mcp
```

| Client | How |
| --- | --- |
| Claude Code | `claude mcp add --transport http open77-devkit https://mcp.open2077.net/mcp` |
| Codex CLI | in `~/.codex/config.toml`: `[mcp_servers.open77-devkit]` then `url = "https://mcp.open2077.net/mcp"` |
| Cursor | Settings › MCP › add a server with that URL |
| claude.ai | Settings › Connectors › add a custom connector with that URL |

The hosted endpoint answers for the latest published build, or the one you name:
`https://mcp.open2077.net/mcp?build=2.31.13+op77.54`. It cannot read your files or reach your
server; the local install does both.

## What the agent can do with it

- **Look up any native** with its signature, the permissions the manifest must declare, the reason
  strings it can return, the first build that has it, and an example from the guides.
- **Read the guides** section by section, the `open77:*` events with their payloads, the manifest
  grammar and the `server.jsonc` schema.
- **Find spawnable names**: vehicles, weapons, clothing, NPC templates, props, effects, sounds,
  animations, from the same tables the server answers `Open77.data.*` from.
- **Translate FiveM**: what to use in place of a FiveM native, and what OPEN//77 deliberately does
  without.
- **Validate a resource** against your build: manifest, scripts, unknown natives, wrong runtime
  side, undeclared permissions, natives newer than the server.
- **Scaffold a resource** that is correct by construction, including the export ownership guard.

Every answer names the build it answers for. A native your server does not have is reported as
*not available*, never guessed.

## Editor completion

```bash
npx -y @open2077/mcp types
```

writes `open77-client.d.lua`, `open77-server.d.lua` and a `.luarc.json` into your resources root.
The Lua language server in VS Code or Cursor then completes `Open77.*` and shows the same card on
hover.

## How it stays current

The MCP reads a documentation index built from this site's content, which is synced from the
platform wiki, which is generated from the client and server source. Each server release publishes
its index; the package refreshes from the CDN at most once a day, verifies every file against a
hashed manifest, and serves its cached or embedded copy when offline, saying so.

## The method it teaches

The MCP serves a skill, `open77-resource-dev`, that agents read before writing a resource. Its
rules are the ones that cost server owners the most when broken: the server is authoritative; a
native exists only if the catalogue returns it; declare exactly the permissions the natives
require; never call a client native from a server script; check the reason a call returns; and
never act server-side on a player who is not alive.
