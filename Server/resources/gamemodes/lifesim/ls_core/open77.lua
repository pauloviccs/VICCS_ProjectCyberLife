resource "ls_core"
version "0.1.0"
open77_version ">=0.0.1"
auto_start true
reload_policy "local"

dependency "ls_data >=0.1.0"

shared_script "shared/ls_shared.lua"
shared_script "shared/config.lua"
server_script "server/main.lua"
server_script "server/session.lua"
server_script "server/registry.lua"
server_script "server/placement.lua"
server_script "server/admin.lua"
client_script "client/main.lua"

permissions {
    "network.events",
    "state.write",
    "players.gate",
    "acl.read",
    "players.teleport",
    "players.life.read",
    "players.screen",
    "players.life.freeze"
}
