---
name: open2077-dev
description: Expert Open2077 development skill for building Cyberpunk 2077 multiplayer resources, server architecture, Lua 5.4 scripting, state bags, REDengine bridge, and NUI (Svelte 5) interfaces.
risk: unknown
source: workspace
date_added: '2026-09-30'
---

# OPEN//77 Development Skill (Cyberpunk 2077 Multiplayer)

You are an expert OPEN//77 developer and systems architect specializing in building robust, performant multiplayer resources for *Cyberpunk 2077* (REDengine 4, game version 2.31+ and Phantom Liberty).

## 1. When to Use This Skill

- Developing, refactoring, or reviewing Open77 server and client resources.
- Designing game systems, lifepaths, roleplay economies, biometrics, housing, or vehicle systems.
- Creating WebView2 NUI interfaces (Svelte 5 Runes or modern vanilla CSS/JS).
- Integrating Redis 7 caching and PostgreSQL 16 transactions.
- Porting FiveM / RedM resources to Open77 and diagnosing Redengine API constraints.
- Validating manifests, permissions, and native Lua signatures against the Open77 build.

## 2. Inviolable Core Principles

1. **Server-Authoritative Authority:**
   - The client NEVER decides or verifies money, inventories, character vital health, entity spawning, or property ownership.
   - The client only renders approved state and transmits sanitized input intents (`events`).
2. **REDengine 64-bit Opaque IDs:**
   - Entity and system IDs from REDengine are 64-bit integers.
   - **NEVER** pass them through `tonumber()`. Store, compare, and transmit them as opaque values.
3. **Failures as Values:**
   - APIs return `val` on success or `nil, reason` (snake_case string) on failure.
   - Check return values instead of wrapping everything in `pcall`.
4. **Explicit Permissions:**
   - Manifests must declare required permissions via `permissions { "network.events", ... }`.
   - Never call client natives on the server or server natives on the client.
5. **Zero VDOM in NUI:**
   - In-game WebUI runs out-of-process in Chromium WebView2. Avoid React or heavy VDOM libraries to eliminate garbage collection pauses. Use Svelte 5 (Runes) or pure HTML5/CSS/JS.

---

## 3. Resource Architecture & Folder Layout

Standard resource structure:

```text
resources/
└── [open77_module]/
    ├── open77.lua          # Authoritative resource manifest
    ├── config.lua          # Shared / configurable settings
    ├── server/
    │   ├── main.lua        # Server entry point
    │   ├── controllers/    # Business logic & net event handlers
    │   └── services/       # Database (Postgres) & Cache (Redis) connectors
    ├── client/
    │   ├── main.lua        # Client entry point
    │   ├── camera.lua      # Scripted cameras & raycasting
    │   └── nui.lua         # WebUI NUI bridge
    └── web/                # Svelte 5 WebUI project
        ├── package.json
        ├── svelte.config.js
        ├── src/
        └── dist/           # Built static assets loaded by WebView2
```

### Manifest Standard (`open77.lua`)

```lua
resource "open77_module"
version "1.0.0"
author "Server Team"
description "Description of the resource"
auto_start true

shared_script "config.lua"

server_scripts {
    "server/services/*.lua",
    "server/controllers/*.lua",
    "server/main.lua"
}

client_scripts {
    "client/camera.lua",
    "client/nui.lua",
    "client/main.lua"
}

web_ui_page "web/dist/index.html"
web_files {
    "web/dist/index.html",
    "web/dist/assets/**"
}

files {
    "assets/blips/*.png",
    "assets/audio/*.wav"
}

permissions {
    "network.events",
    "world.loot"
}

-- Declarative Exports (registers global function of that name)
exports { "ClientAction" }
server_exports { "GetPlayerData", "UpdateVitals" }
```

> **Manifest Rules:**
> - `@other_resource/file.lua` cross-resource includes are **prohibited** and will fail manifest parsing.
> - FiveM metadata tags (`fx_version`, `game`, `lua54`) are tolerated but ignored (`manifest_ignored_keys`).
> - Use `preload_mod "dist/archive.zip"` only for pre-boot `.archive` REDengine assets.

---

## 4. Networking & State Synchronization

### A. Net Events
```lua
-- Server to Client:
TriggerClientEvent("open77:event", targetId, payload)
TriggerClientEvent("open77:event", -1, payload) -- broadcast

-- Client to Server:
TriggerServerEvent("open77:requestAction", data)

-- Server Listener:
RegisterNetEvent("open77:requestAction", function(source, data)
    local src = source -- authenticated playerId
    if not src or src <= 0 then return end
    -- Process with validation...
end)
```

### B. State Bags (Preferred for State Replication)
```lua
-- Server assigns state (replicated to all clients):
Entity(ped).state:set("nutrition", 85, true)
Player(src).state:set("job", "ripperdoc", true)

-- Client reactive listener:
AddStateBagChangeHandler("nutrition", nil, function(bagName, key, value, _reserved, replicated)
    -- Update HUD or trigger visual effect
end)
```

### C. Network Callbacks (`Open77.net`)
```lua
-- Server RPC Handler:
Open77.net.handle("module:queryVitals", function(source, args)
    return { status = "stable", stability = 95 }
end)

-- Client RPC Call:
local res, err = Open77.net.call("module:queryVitals", {})
if not res then
    print("Callback failed: " .. tostring(err))
end
```

---

## 5. REDengine 4 & FiveM Compatibility Rules

| FiveM Idiom | Open77 Reality | Action Required |
| :--- | :--- | :--- |
| `GetHashKey("model")` / `joaat` | Returns **TweakDBID** (CRC32/ISO + length), NOT GTA Jenkins hash | Use full TweakDB strings like `"Vehicle.v_sport2_quadra_turbo_r"` |
| `RequestModel` / `HasModelLoaded` | **Does not exist** | Delete these calls. REDengine streams assets dynamically. |
| `Citizen.CreateThread` / `Wait` | Built-in identical aliases | Safe to use. |
| `SetTick(fn)` / `ClearTick(id)` | Supported | Cancels automatically after 5 consecutive unhandled exceptions. |
| `IsDuplicityVersion()` | Supported | `true` on server, `false` on client. |
| `SetPedToRagdoll` | Server-only | `Open77.players.ragdoll(id, { durationMs = 3000 })`. |
| `LoadResourceFile` | Sandboxed | Denied across different resources (`cross_resource_read_denied`). |

---

## 6. NUI (Chromium WebView2) Protocol

1. **Client Lua -> WebUI:**
   ```lua
   SendNUIMessage({
       action = "UPDATE_HUD",
       data = { neuralStability = 82, nutrition = 94 }
   })
   ```
2. **WebUI -> Client Lua:**
   ```javascript
   fetch("https://open77-webui/actionSubmit", {
       method: "POST",
       headers: { "Content-Type": "application/json" },
       body: JSON.stringify({ item = "neuroblocker_v1" })
   });
   ```
3. **Client Handler:**
   ```lua
   RegisterNUICallback("actionSubmit", function(data, cb)
       -- Forward request to server
       TriggerServerEvent("open77:consume", data.item)
       cb({ ok = true })
   end)
   ```
4. **Kiroshi Diegetic Theme Guidelines:**
   - Backdrop: `#080E19` at 85% opacity with `backdrop-blur-md`.
   - Accent: Electric Cyan (`#22D8E2`) and Crisp White (`#F2F6F8`).
   - Warning / Cyberpsychosis: Neon Red (`#FF5964`).
   - Fonts: Monospace for numbers (`JetBrains Mono`, `Chakra Petch`).

---

## 7. Performance & Optimization Invariants

- **Adaptive Tick Rates:** Never run tight loops (`Citizen.Wait(0)`) when idle. Use 500ms+ poll intervals when not actively in collision or interaction range.
- **Write-Behind Caching:** High-frequency biometrics (vitals decay, coordinates, stress) update in Redis 7 (in-memory). A server cron flushes deltas to PostgreSQL 16 every 5 minutes.
- **Immediate Financial Locking:** Currency and property transactions must bypass caching and execute immediate ACID transactions on PostgreSQL via `Open77.database`.

---

## 8. Development Tools & MCP Commands

When working with OPEN//77 resources:
- Run `npx -y @open2077/mcp types` in the server root to update autocomplete definitions (`open77-client.d.lua`, `open77-server.d.lua`, `.luarc.json`).
- Leverage MCP tools:
  - `open77_search`: Search natives and documentation.
  - `open77_api`: Inspect exact native signatures and return codes.
  - `open77_data`: Look up TweakDB vehicle, weapon, and NPC records.
  - `open77_validate`: Run static checks on resources and manifests.
