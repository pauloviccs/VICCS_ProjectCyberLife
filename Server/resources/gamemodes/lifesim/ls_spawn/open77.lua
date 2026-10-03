resource "ls_spawn"
version "0.1.0"
open77_version ">=0.0.1"
auto_start true
reload_policy "reconnect"

dependency "ls_core >=0.1.0"
dependency "ls_data >=0.1.0"

shared_script "shared/config.lua"
client_script "client/main.lua"
server_script "server/main.lua"

web_ui_page "web/index.html"
web_ui_auto_create false
web_files { "web/**" }
files { "web/**" }

permissions {
    "webui.system",
    "input.actions",
    "network.events",
    "local.events",
    "players.controls",
    "players.life.freeze",
    "player.travel",
    "players.screen",
    "world.query"
}
