---@diagnostic disable: undefined-global
resource "ls_cyberware"
version "0.1.0"
open77_version ">=0.0.1"
auto_start(true)
reload_policy "local"

dependency "ls_core >=0.1.0"
dependency "ls_data >=0.1.0"
dependency "ls_vitals >=0.1.0"
dependency "ls_inventory >=0.1.0"

shared_script "shared/ls_shared.lua"
shared_script "shared/config.lua"
server_script "server/main.lua"
client_script "client/main.lua"

permissions {
    "network.events",
    "state.write",
    "state.read"
}
