# Open77 connection workspace

Trusted client bootstrap, not a downloadable gamemode menu. The launcher owns server selection,
history, direct connect and mod consent. This resource displays connection progress and recovery
without maintaining another directory. See [Connection flow](../../../wiki/connection-flow.md).

The UI uses local Open77 tokens/fonts and a responsive Bento/Metro grid. Lobby audio is an owned
local MP3 at `web/audio/lobby.mp3`, looping at 12% by default. The bottom-right dock persists
pause/volume as one `lobby:music` JSON value in this trusted resource's device-local KVP.
It is paused whenever the shell is hidden or a custom loadscreen takes over.

Regression checks:

- `scripts/tests/connection-ui-browser.cjs` loads the actual CEF bridge and real HTML/CSS/JS;
  set `OP77_PLAYWRIGHT` to an installed Playwright module when it is not resolvable on Node's path.
  Screenshots/results go to ignored `artifacts/connection-ui`.
- `ConnectionShellLuaTests` runs `tests/connection_test.lua` via the server test runner, exercising
  cancellation/stale timers, retry, failures, preferences and launcher dispatch without REDengine.
- Native scripting tests cover launcher permission checks and KVP scope. Live game and Warden
  observations are recorded in `docs/research/main-menu-and-server-browser.md`.
