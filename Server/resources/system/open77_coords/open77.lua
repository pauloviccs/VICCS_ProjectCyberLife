---@diagnostic disable: undefined-global
resource "open77_coords"
version "1.0.0"
open77_version ">=0.0.1"
auto_start true
reload_policy "reconnect"

shared_script "shared/config.lua"
server_script "server/main.lua"
client_script "client/main.lua"

web_ui_page "web/index.html"
web_ui_auto_create false
web_files { "web/**" }
files { "web/**" }

permissions {
    "webui.system",
    "network.client",
    "network.events",
    "local.events",
    "input.actions",
    "acl.read",
    "clipboard.write"
}
