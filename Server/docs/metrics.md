# Prometheus server metrics

The dedicated server exposes a read-only `GET /metrics` endpoint in Prometheus
text exposition format 0.0.4. It collects continuously: no Warden browser, RCON
connection, active recording, Lua package or client update is required.

## Enable

Add this section to `server.jsonc`, then restart the server:

```json
"metrics": {
  "enabled": true,
  "listenUrl": "http://127.0.0.1:11783",
  "tokenEnvironmentVariable": "OP77_METRICS_TOKEN"
}
```

Metrics are **disabled by default**. The default listener is loopback-only and
independent of the game UDP port, resource download HTTP server, Warden and RCON.
Assign a different metrics port to each server instance on the same host.
`HEAD /metrics` returns the same headers without the body. Other routes return
404; unsupported methods return 405. No endpoint can run commands or modify state.

Check locally:

```sh
curl --fail http://127.0.0.1:11783/metrics
```

### Authentication and remote access

Set the environment variable named by `tokenEnvironmentVariable` to a randomly
generated secret of 32–256 printable ASCII characters, with no spaces. Restart
the service so it receives that environment. Do not put the secret in the JSON
configuration, a URL, version control or a dashboard screenshot.

When a token is configured, **every** scrape requires `Authorization: Bearer ...`,
including loopback scrapes. A non-loopback bind such as `http://0.0.0.0:11783`
**refuses startup without a token**. Hostnames other than `localhost`, URL paths,
credentials, query strings and multiple listener URLs are rejected.

The built-in listener uses HTTP. Bearer authentication is not encryption: keep it
on loopback behind a TLS reverse proxy, or use a trusted private network/tunnel.
Do not expose the plaintext listener to the public Internet. Apply firewall rules
allowing only your collector. The token grants metrics access only, not administration.

## Prometheus configuration

For a collector on the same host, without an environment token:

```yaml
scrape_configs:
  - job_name: open77
    scrape_interval: 5s
    scrape_timeout: 3s
    metrics_path: /metrics
    static_configs:
      - targets: ['127.0.0.1:11783']
        labels:
          server: freeroam-german
          channel: unstable
```

If a token is configured, add this to the job. The file contains only the token
and must be readable only by the Prometheus service account:

```yaml
    authorization:
      type: Bearer
      credentials_file: /etc/prometheus/open77-metrics-token
```

For a TLS reverse proxy, use `scheme: https` and its hostname/port in `targets`.
Container loopback is the container itself: route to the server through a private
network instead of assuming `127.0.0.1` reaches the host.

Prometheus stores the history; Grafana can visualize it with a Prometheus data
source. This endpoint does not persist a time series or replace the existing
[Warden performance captures](warden-performance.md), which remain available.

## Collection and interpretation

- The simulation publishes measurements about once per second. Every completed
  window contributes to counters, even when Warden skips an intermediate window.
- Process/GC sampling and text rendering run on background workers, also at 1 Hz.
  HTTP serves cached bytes and does not call Lua, enumerate entities, query SQL or
  poll the transport. Scraping faster than 1 Hz adds no useful resolution.
- Counters ending in `_total` accumulate until process restart unless otherwise
  described. Use `rate()`/`increase()`, which handle resets. Scrapes never drain them.
- Gauges describe current state or the latest window. Missing optional diagnostics
  mean **unavailable**, not zero. Check availability and timestamp metrics.
- Tick, lateness and database histograms accumulate exact disjoint observations
  into cumulative buckets, including `+Inf`. `*_window_seconds{statistic=...}`
  contains the existing latest-window approximate percentiles, not Prometheus
  histogram quantiles; never average those percentiles across servers.
- Histogram bounds in seconds are: `0.0001, 0.00025, 0.0005, 0.001, 0.0025,
  0.005, 0.01, 0.016667, 0.033334, 0.05, 0.1, 0.25, 0.5, 1, 5, 10, +Inf`.
  Above the final finite bucket, use sum/count and latest-window max as well.

## Exported families

Every family includes `HELP` and `TYPE` lines. The endpoint is the complete
field-level inventory; optional families appear when their data source exists.

| Domain | Metrics / meaning |
|---|---|
| Build and capacity | `open77_build_info`, `process_start_time_seconds`, `open77_uptime_seconds`, `open77_players_capacity`, configured tick/snapshot rates |
| Connections | `open77_connections`, `open77_admissions_pending`, `open77_players_connected`, `open77_players_ready`, joins/departures and connection rejections by bounded protocol reason |
| Gameplay | `open77_players_life_state{phase}`, life transitions, deaths by cause, attributed kills, completed respawn/revive recoveries, accepted combat hits and damage by attack kind |
| World | `open77_entities{kind}` for vehicles, NPCs, props, effects, loot, elevators and destruction records; creation/removal counters for NPCs, vehicles, props and effects |
| Visibility | `open77_routing_buckets_occupied`, `open77_interest_relationships`; no bucket or player identifiers |
| Vehicles | Owned/unowned, moving, destroyed, stale motion, active simulators, maximum per-simulator vehicle count, AI jobs/states, authority changes, rejected NPC/vehicle motion |
| Tick | `open77_tick_duration_seconds`, `open77_tick_lateness_duration_seconds`, over-budget counters, latest-window mean/p50/p95/p99/max and window duration |
| Process CPU/RAM | `process_cpu_seconds_total`, `process_resident_memory_bytes`, `open77_process_cpu_cores`, `open77_process_cpu_ratio`, logical processors and threads |
| .NET | `open77_dotnet_heap_bytes`, GC committed bytes, allocated bytes total/rate, GC pause seconds, collections by generation, thread-pool threads and pending work |
| Linux host CPU | `open77_host_cpu_busy_ratio{cpu}`, `open77_host_cpu_steal_ratio`, when `/proc/stat` can be read |
| Lua resources | Resource states, running flag, VM memory, reload generation, scheduler/event wall time, scheduler invocations, max duration, failures and slow ticks |
| Replication | `open77_replication_stage_{calls,items,seconds,allocated_bytes}_total{stage}` and network poll wall time |
| Transport | `open77_transport_*`: application bytes/messages, send failures, current native connection diagnostics, latency/quality where available, pending native queues and throughput estimates |
| Protocol | `open77_transport_message_bytes_total{kind,direction}` identifies bandwidth-heavy protocol kinds |
| Send scheduling | All numeric `open77_transport_send_queue_*` and `open77_transport_timed_queue_*` diagnostics: pending frames/bytes, oldest ages, attempts, sends, budget skips, coalescing/drops and backlog |
| Native lanes | `open77_transport_lane_*{lane}`: numeric lane diagnostics over current connections. **Gauges**, even for native accepted-byte totals, because disconnecting a peer removes its contribution |
| Net events | `open77_net_events_total`, `open77_net_event_messages_total`, `open77_net_event_bytes_total`; outbound resource/event attribution and aggregated inbound traffic |
| Voice | All numeric `open77_voice_*` router diagnostics, including active talkers/participants/channels and cumulative routing/drop counters |
| Database | Enabled/reachable, latest probe and success timestamps, submitted/completed/failed operations, queued/executing requests, completion backlog, returned rows, truncated results, duration histogram by operation |
| Health | `open77_loop_stale`, loop/sample/render timestamps, sampler missed intervals/skipped windows, warning/error log totals, exporter render duration/response size and HTTP 200/401 counters |

Transport and voice record fields use snake_case. Milliseconds become seconds,
percentages become ratios, and lifetime counter fields receive `_total`.
`open77_transport_metrics_available` distinguishes missing transport diagnostics.

### Important boundaries

CPU in `open77_process_cpu_cores` uses **one fully busy logical core = 1**; the
normalized `open77_process_cpu_ratio` divides by the process's available logical
processors. Process RSS is not the machine's total RAM. Lua memory is VM-reported,
not exclusive resident memory. Resource scheduler and event timings measure wall
time, not CPU instructions; nested replication timings overlap and must not be summed.

Network bytes are application/transport observations, **not** total NIC bandwidth
including UDP/IP headers, retransmission overhead or a guarantee of delivered latency.
Native quality and latency diagnostics depend on the transport backend.
For disk space/I/O, whole-machine RAM, kernel UDP drops and NIC traffic, collect a
host exporter alongside this endpoint. FPS, GPU use and client RAM cannot be inferred
from server counters; those would require an explicit client-telemetry feature.

Database request timings cover the **resource SQL bridge**, including thread-pool,
connection and execution waits. They do not measure every internal persistence
subsystem's SQL. No SQL, parameters or connector error messages are exported.

`ready` means the resource readiness gate passed, not that a native visual frame was
rendered. Kills follow authoritative death attribution; they are not a PvP leaderboard.
Economic balances, race results and RP job outcomes are gamemode-specific: use the
Lua API below rather than expecting the server to guess their meaning.

## Useful queries

Filter by your `server`/`instance` label when selecting one instance.

```promql
# Connected versus ready players
open77_players_connected
open77_players_ready

# Tick p95 over five minutes, milliseconds
histogram_quantile(0.95, sum by (instance, le) (
  rate(open77_tick_duration_seconds_bucket[5m])
)) * 1000

# Actual observed tick rate and fraction of ticks over budget
rate(open77_tick_duration_seconds_count[1m])
rate(open77_tick_over_budget_total[5m])
  / clamp_min(rate(open77_tick_duration_seconds_count[5m]), 0.001)

# CPU core equivalents; resident memory in MiB
rate(process_cpu_seconds_total[5m])
process_resident_memory_bytes / 1024 / 1024

# Outbound application bandwidth in megabits/s; protocol cost
rate(open77_transport_sent_bytes_total[1m]) * 8 / 1000000
topk(10, rate(open77_transport_message_bytes_total{direction="sent"}[5m]))

# Most expensive resource schedulers in wall seconds/second
topk(10, rate(open77_resource_scheduler_seconds_total[5m]))

# GC pause share, deaths and database operation failure rate
rate(open77_dotnet_gc_pause_seconds_total[5m])
sum by (instance) (increase(open77_player_deaths_total[5m]))
rate(open77_database_operation_failures_total[5m])

# Detect cached-but-stalled data even while HTTP still answers
time() - open77_loop_last_update_timestamp_seconds > 5
time() - open77_exporter_sample_timestamp_seconds > 5
time() - open77_exporter_render_timestamp_seconds > 5
up{job="open77"} == 0
```

For capacity planning, compare equally long windows at different player counts:
tick p95/p99, CPU, allocation/GC rate, bandwidth and queue ages together. A small
average tick does not rule out tail stalls. Dividing total RSS by player count
includes the fixed server baseline; it is **not** marginal RAM per extra player.
Do not extrapolate one low-population measurement linearly to hundreds of players.

## Custom gameplay counters from Lua

Server scripts can contribute bounded, resource-labelled metrics. Add:

```lua
permissions { 'metrics.write' }
```

```lua
-- Server-side only. No-op failure when metrics is disabled: false, 'metrics_disabled'.
local ok, reason = Open77.metrics.increment('shop_sales')
Open77.metrics.increment('cash_spent', 250)
Open77.metrics.gauge('race_participants', #participants)
Open77.metrics.observe('job_run_duration', elapsedMilliseconds / 1000)
```

| Call | Export |
|---|---|
| `increment(name, amount = 1)` | `open77_gameplay_<name>_total{resource="your_resource"}` counter |
| `gauge(name, value)` | `open77_gameplay_<name>{resource="your_resource"}` current value |
| `observe(name, seconds)` | `open77_gameplay_<name>_seconds{resource="your_resource"}` histogram family |

All return `true` or `false, reason`. Names must match `[a-z][a-z0-9_]*`, be
1–64 characters and not end in `_total`, `_bucket`, `_sum`, `_count` or `_seconds`.
A name's type is fixed across resources. Values must be finite, with absolute
value at most `1e100`; counters and observations must be non-negative.

Reasons include `permission_denied:metrics.write`, `metrics_disabled`,
`invalid_metric_arguments`, `invalid_metric_name`, `invalid_metric_value`,
`metric_type_conflict` and `metric_limit`.

Limits are lifetime limits until server restart: 32 names per resource and 512
resource/name pairs globally. Counters/histograms survive resource restarts;
current custom gauges reset on an explicit resource stop. Set gauges on startup
and update them as gameplay changes. Do not emit metrics as a side effect of
speculative hot-reload initialization: a discarded candidate's increments cannot
be rolled back. Prefer runtime events after the resource has started.

Never encode player names, IDs, IPs, email addresses, SQL, arbitrary item instances
or timestamps into metric names. There are deliberately no caller-supplied labels.
The resource label is supplied by the host, not by Lua.

## Cardinality and privacy

Built-in labels use bounded enums/protocol kinds and resource names, not player
identities. All inbound client event names are aggregated. Outbound event labels
have a lifetime budget of 256; excess labels are aggregated. Named resource
diagnostics also have a lifetime budget of 256, then use `resource="overflow"`;
its timings/memory/counts aggregate, and no meaningless generation is emitted.
`open77_resource_names_aggregated` reports the current overflow size. Removed
resources no longer report running/memory usage; their cumulative counters remain.
The registry has a final ceiling of 32,768 sample series.

Treat the endpoint as operational data nonetheless: build versions, installed
resource names, outgoing event names and load can reveal server internals.

## Validation and troubleshooting

Use the Prometheus distribution's validator against the response:

```sh
curl --fail --silent http://127.0.0.1:11783/metrics | promtool check metrics
```

A 401 means a missing/wrong Bearer header; query-string tokens are not accepted.
A refused startup on a remote bind means the token was absent or invalid.
If HTTP is healthy but the loop timestamp stops advancing, investigate the game
loop rather than increasing the scrape frequency. If CPU/RAM timestamps stop too,
check the sampler and process. Missing database/host/native metrics may simply
mean that subsystem is disabled or unavailable on this platform.
