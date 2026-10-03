# open77_watermark

Compact, passive **Open Stress Test** session signature, centred at the top of
the HUD. The OPEN//77 logo and event label sit above a quiet metadata line:
player name and ID, runtime build, shortened session identifier. The previous
Pre-alpha / private-test notice and visible Lua/generation details are removed.

## Behaviour

- Remains inside `CHROME_STRIP` (top 7%); never enters the gamemode match band.
- Passive `hud` WebUI: no focus, no pointer events, transparent, 10 fps.
- Small translucent backing keeps text readable against sky and dark scenes.
  No blur, continuous animation, blinking or large full-width banner. Only a
  short entrance fade and status-colour transition; reduced motion is respected.
- Long names/builds truncate before displacing the session identifier. Short
  viewports use one row and omit the build; narrow ones omit redundant labels.
- The session status dot is cyan only after an authoritative server answer.
  Before that, or after a missed refresh, it is muted and displays `OFFLINE`.
- Client runtime facts and the `watermark:ready` / `watermark:state` protocol are
  unchanged. Server replies contain the authenticated player ID, resolved name
  and persistent identifier; the full identifier is never inserted into the DOM.
- Refresh cadence remains 60 seconds online / 5 seconds offline, with no new
  timers or network calls. Session identifiers retain their `8…4` abbreviation
  for correlating screenshots with server logs.

## Editing / validation

The event label lives in `web/index.html`; appearance in `web/app.css`; safe
text-only rendering in `web/app.js`. The existing packaged logo is reused.

Run `node scripts/tests/watermark-browser.cjs` from the repository root with
Playwright installed (or set `OP77_PLAYWRIGHT` to its module path). The browser
checks cover layout, passive input, identity updates, offline transitions, long
names, hostile text and reduced motion. They do not launch the game.
