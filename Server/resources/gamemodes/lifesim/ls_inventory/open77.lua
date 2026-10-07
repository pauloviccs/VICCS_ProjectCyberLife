resource "ls_inventory"
version "0.1.0"
open77_version ">=0.0.1"
auto_start true
reload_policy "reconnect"

dependency "ls_core >=0.1.0"
dependency "ls_data >=0.1.0"

shared_script "shared/config.lua"
shared_script "shared/items_catalog.lua"
shared_script "shared/crafting_recipes.lua"
client_script "client/main.lua"
server_script "server/main.lua"

permissions {
    "network.events",
    "local.events",
    "input.actions",
    "database.access"
}
