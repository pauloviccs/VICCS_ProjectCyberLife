# PolyZone for Open77

Polygon, oriented box, circle/sphere, moving entity and combined zones for
Open77 Lua resources. The package is named **`polyzone`**. It adapts the
functional API of [PolyZone 2.6.2](https://github.com/mkafrin/PolyZone), under
its MIT license, to Open77 entities, isolated Lua VMs, native drawing and WebUI.
It does not require FiveM, GTA natives, a Redscript bridge or another mod archive.

Requires the Open77 client containing `require('@dependency')`,
`Open77.world.entityGeometry` and `Open77.debugDraw` from this change. An older
CDN client cannot load the library until that client update is published.

## Install

Put this directory under your server's resource root and include `polyzone`
in `resources.load`. Include your consuming resource too. In its `open77.lua`:

```lua
resource 'my_job'
version '1.0.0'
dependency 'polyzone >=1.0.0'
client_script 'client.lua'
permissions { 'world.query' } -- player position and entity queries
```

Use `world.debug` for debug geometry, `ui.vanilla.map` for debug blips, and
`network.events` / `local.events` when using zone-filtered network/local events.
Permissions belong to the **consumer**, not the library it imports.

```lua
local PZ = assert(require('@polyzone'))
local garage = PZ.BoxZone:Create({x=-800, y=600, z=30}, 12, 8, {
    name='garage', heading=45, minZ=29, maxZ=34,
    data={job='mechanic'}, debugPoly=false,
})
local cancel = garage:onPlayerInOut(function(inside, position)
    print(inside and 'Entered garage' or 'Left garage')
end, 250)
-- cancel() stops this watcher; garage:destroy() removes the entire zone.
```

For familiar class names, `require('@polyzone').installGlobals()` installs
`PolyZone`, `BoxZone`, `CircleZone`, `EntityZone`, `ComboZone` in **your VM only**.
Do not list `@polyzone/client.lua` as a manifest script: import the library.
Wrappers such as `require('@polyzone/BoxZone')` are also provided.

## Documentation

See [the full guide](../../wiki/polyzone.md) for the API, groups, events,
entity references, editor, lifecycle, permissions and platform differences.

The editor is opened using `/pzcreate poly|box|circle [name]`, or `/pzedit`.
F9 releases/reacquires focus; F10 adds polygon vertices at your feet.
Grant the relevant `command.pz*` permissions to trusted developers. Zone files
are saved to this resource's **`data/polyzone_created_zones.txt`**, not executed.

## Tests

Build/run the CMake test `Open77.Scripting.PolyZone`. It tests the actual Lua
library, geometry/grid agreement, transitions, streaming, typed entity input,
debug bindings, dependency imports, caller permissions and reload cleanup.
No game or public server is needed for this deterministic suite. Native mesh
bounds and rendered editor geometry additionally require validation in-game.
