---@diagnostic disable: undefined-global
resource "ls_economy"
version "0.1.0"
open77_version ">=0.0.1"
auto_start true
reload_policy "reconnect"

dependency "ls_core >=0.1.0"
dependency "ls_data >=0.1.0"
dependency "open77_contextmenu >=1.1.0"
dependency "open77_interactions >=0.1.0"

shared_script "shared/ls_shared.lua"
shared_script "shared/config.lua"
server_script "server/main.lua"
client_script "client/main.lua"
client_script "client/targets.lua"
client_script "client/blips.lua"

permissions {
    "network.events",
    "local.events",
    "state.write",
    "acl.read",
    "database.access",
    "ui.vanilla.map",
    "map.read",
    "input.actions",
    "world.query"
}
