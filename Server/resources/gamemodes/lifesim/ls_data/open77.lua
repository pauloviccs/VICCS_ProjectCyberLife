resource "ls_data"
version "0.1.0"
open77_version ">=0.0.1"
auto_start true
reload_policy "local"

shared_script "shared/ls_shared.lua"
server_script "server/services/database.lua"
server_script "server/services/migrations.lua"
server_script "server/services/cache.lua"
server_script "server/main.lua"

permissions {
    "database.access"
}
