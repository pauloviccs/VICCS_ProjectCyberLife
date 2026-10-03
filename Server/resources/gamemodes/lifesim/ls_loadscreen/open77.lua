resource "ls_loadscreen"
version "0.1.0"
open77_version ">=0.0.1"
auto_start true
reload_policy "reconnect"

shared_script "shared/config.lua"

loadscreen "web/index.html"
web_ui_page "web/index.html"
web_ui_auto_create false
web_files { "web/**" }
files { "web/**" }

permissions {
    "network.events",
    "local.events"
}
