# Cyberware projection and optional charge presentation

The client projects authoritative implant equipment, observer arm profiles and
living-player reactions. The server presentation script is replaceable policy
using the public `Open77.cyberware.activity`, `Open77.effects.attach/remove` and
`Open77.players.all` APIs. It does not install implants, change damage, charge
money or define progression.

After a previously ready double-jump projection is lost, the client asks the
server to restore its committed equipment under a fresh projection. The native
legs monitor tolerates the short stat-restoration delay when a race grid releases
NoMovement. Update both this resource and the client REDscript for this recovery.

Edit `server/presentation-config.lua` to disable additional charge effects,
choose effects per grade, override a definition, or require fully charged state.
The bundled training, industrial and cosmetic grades opt in; unknown grades have
no extra visual until configured. Each accepted hold creates one effect with
`remainingMs + 250` lifetime and removes it on release, rejection, stale activity,
disconnect or resource stop. There are no heartbeat renewals or repeated particle
spawns for a continuous hold. The server's configured maximum charge time bounds
the effect independently of client input.

The default uses the installed game's `electric.industrial_arm` asset for
observers on body `RightHand`, a documented visual substitute with no electric
damage. The owner selects the native `spy_perk_charge` weapon event through
the generic `localEvent` attachment option. Its bilateral cyan FPP particles and
eight-second expiry were verified in isolated probes with `breakAllLoops=false`.
Remove `defaults.localEvent` to use world-effect projection in both views, or
select another authored event for your own implant. The complete synchronized
hold workflow, movement/holstering and both families still need final acceptance.

`feedback.enabled` controls messages for server-rejected stamina/cooldown actions.
Messages are configured locally, sent only to the affected player and throttled.
Native maximum-hold feedback is not duplicated. The authority notification is a
server-local handler, not a client-triggerable event.

Keep the client support resource enabled to project installed implants. To replace
only charge visuals, set `CyberwarePresentation.enabled=false` and implement your
own server resource with `players.cyberware.read` and `world.effects`; use the
same public APIs. Installed ownership, grades and RP rules stay with the implant
definition and doctor/arena resources.

The same optional presets configure audio. `chargeSoundEvent` defaults to the
installed StrongArms `w_cyb_strongarms_spy_perk_charge` event and shares the charge
attachment's bounded lease and cleanup. `soundOnOwner` defaults to true; owner
duplication has not yet been measured. Set `chargeSoundEvent=false` to disable it.
An accepted `onCyberwareMeleeHit` snapshot selects `impactSoundEvent` (default
`w_cyb_npc_strongarms_hit_face`) and plays one spatial sound at the victim using
public `Open77.effects.sound`. `impactSoundDuration` defaults to five seconds;
`impactSoundsByBodyPart` can map numeric body-part IDs to other authored names.
Set `impactSoundEvent=false` to disable the default. Zero-damage outcomes are
silent unless `soundOnZeroDamage=true`. Duplicate action/victim notifications
are suppressed. Blocked outcomes do not use this hit event. Existing replicated
swing audio is unchanged. Integrated charge/impact audibility, spatial placement
and owner duplication still require two-client recording acceptance.

Run `python scripting/tests/cyberware_presentation_test.py` from the repository
root to execute the actual server Lua with public-API doubles. This covers
bounded holds, preset selection, release/freshness cleanup, creation failure,
disconnect, resource stop, feedback, charge audio options and accepted-impact
snapshot attribution/deduplication. It is not evidence of rendered or audible effects.

Capability discovery: call `Open77.exports.call("open77_cyberware", "capabilities")`
and await its returned promise inside `CreateThread`, on either side. `exports`
is a publication function, not an indexed proxy. The server describes backend
support/limits, never client readiness.
The client reports its local owned projector phase and sanitized reason; native
equipment readback is explicitly not visual proof. Supported male/female profiles
are declared adapter support;2.31 is a tested build, while actual game build and
DLC verification remain unknown. This read-only export does not probe by equipping
items or disclose another player's implant state. See wiki/cyberware.md for shape.

## Legs projection and second-jump decisions

The full projection ticket can carry independent `record.arms` and
`record.legs`. The latter uses `profile="double_jump"`. A successful ticket ACK
requires both native equipment transactions and their configuration; the
Gorilla visual is retained. Removal projects legs off and retains arm state.
The arm and leg phases share a bounded twelve-second attempt. Failure is
reported to the authoritative transaction for rollback; a native request handle
alone never commits an installation.

`legsActivity()` observes a native buffered second-jump intent. Support sends
one `open77:cyberware:jump` request per native request/sequence and accepts only
the matching incarnation/sequence `jumpResult`. The native grant is bound to its
original equipment request and can be consumed once. Stale, duplicate, removed
or retired-body results cannot activate it. Native timeout and native vanilla
predicates still apply after backend approval. Resource stop releases owned leg
equipment; death/unbind stops activation reporting. No jump audio or particles
are synthesized by this resource.

The capabilities export retains its original `profile` field and adds
`implantProfiles={"gorilla_arms","double_jump"}` and client `legsProjection` native
readiness. `visualProof` remains false. These are separate from live acceptance.

The read-only client `legsActivity` resource export lets other bundled resources
observe the support owner's `{sequence,phase,grounded,airborneMs,verticalSpeed}`
without exposing native request handles or approval authority. Call it through
`Open77.exports.call("open77_cyberware", "legsActivity")` and await the promise.
Unavailable bodies return nil/reason; results are fresh tables. A direct native
`legsActivity()` call in another VM does not have this resource's ownership.


## Ground Slam session ability (protocol 1.28)

`client/ground-slam.lua` owns native grant projection, normal configurable key
input (default G), exact server permits/phases and checked server-selected
geometry. This is a session entitlement, not another durable implant slot.
The capability export includes `ground_slam` in `abilityProfiles` and retains
separate implant profiles. `slamProjection` reports native state/action phase,
never visual proof; live Ground Slam acceptance is pending.

The support manifest requires `player.abilities.project`,
`player.abilities.read`, `input.actions`, `world.query` and its existing network
permissions. Creator server resources need `players.abilities.define`,
`players.abilities.manage`, `players.abilities.read`. Grant/revoke through
`Open77.abilities`, equip a native blunt weapon, close captured UI and press the configured key (L in the lab);
ordinary landing is not activation. No legs implant is imposed by core policy.

[The Ground Slam wiki](../../../wiki/ground-slam.md) contains a copyable public
resource example, configuration bounds, lifecycle ownership, normal key workflow
and honest native/world-evidence limitations. Its `slamActivity` support export
allows diagnostics through an awaited public export call without exposing native
request handles. Existing paid arm/leg records are not touched by ability grants.

Native preflight must report `eligible` before support sends a Ground Slam
intent that could spend canonical stamina. Pending/prerequisite rejection and
preflight timeout remain local; the request, preflight and grant share 750 ms.
Only server-managed stamina is accepted. If the native lease disappears or
loses ready state, support sends a negative projection ACK even if the numeric
engine ID was recycled; it cannot retain an apparently ready retired body.
