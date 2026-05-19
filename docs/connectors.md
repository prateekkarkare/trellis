# Connectors guide

How to think about wiring external data sources into Trellis.

For the per-connector setup notes, see [`connectors/README.md`](../connectors/README.md) and each `connectors/<name>/README.md`.

---

## When to add a connector

**Add one when:** the data is genuinely useful for weekly-review signal and isn't easily reconstructable from your own answers ("did the run happen?" — Todoist knows). **Don't add one when:** you'd just be importing context that doesn't change what the mentor recommends.

Rough priority order:

1. **Task completion** (Todoist, Things, TickTick, OmniFocus, etc.) — the single highest-value connector. Without it, the weekly review is asking you what happened; with it, you're being shown what happened. Hugely different signal.
2. **Calendar** — second most useful. Distinguishes "didn't do" from "was triple-booked".
3. **Activity tracking** (Strava, Apple Health, Whoop, etc.) — only if you have a body/fitness domain that needs this granularity. Often the weekly summary in your phone is enough.
4. **Work context** (Slack, email-volume signal) — only if work pressure routinely explains domain-throughput dips. High privacy cost, calibrate accordingly.
5. **Money** (Plaid, YNAB, etc.) — only if you have a finances domain. Read-only.

## Three integration patterns

### Pattern A — MCP server (preferred)

If the service has an MCP server, point your LLM client at it. The mentor calls MCP tools at protocol time. Pros: zero infrastructure. Cons: bound to whatever the MCP server exposes; some services don't have one yet.

### Pattern B — Flat-file dump (most durable)

A cron/script writes daily exports to `connectors/<name>/data/`. The mentor grep's across them at protocol time. Pros: completely durable, debuggable, works offline, replays infinitely. Cons: setup friction; you write the export script.

### Pattern C — Direct API at protocol time

The mentor itself calls the API. Pros: no pre-fetch needed. Cons: secrets management, rate-limit risk, can't replay history if the API breaks. Use only when A and B are impractical.

## What signal each one provides to the protocols

| Connector | Signal | Used by |
|---|---|---|
| Todoist | task completion %, comments, reschedule patterns, time-of-completion | WEEKLY_REVIEW Phase 1 (primary) |
| Calendar | locked slots, completion vs collision | WEEKLY_REVIEW Phase 1 + Phase 4 |
| Activity tracker | strain, recovery, sleep | DOMAIN_SESSION (fitness only) |
| Slack | work-context noise floor | WEEKLY_REVIEW Phase 1 (framing) |
| Email volume | proxy for work-week intensity | WEEKLY_REVIEW Phase 1 (framing) |
| Finances | balance, runway, transaction counts | DOMAIN_SESSION (finances only) |

## Graceful degradation

The protocols are written so that **any connector being unavailable is non-fatal**. WEEKLY_REVIEW Phase 1 explicitly says: *"If Todoist is unavailable, fall back to log.md and flag the gap at Checkpoint 1."* Mentors do not refuse to run without a connector — they degrade their signal and tell you so.

This matters because:

- Connectors break. APIs change. MCP servers crash.
- You'll travel and lose access.
- You'll change services and the new one isn't wired yet.

The framework outlasts any specific connector by design.

## Secrets discipline

- Never commit credentials. The `.gitignore` excludes `connectors/connectors.yml`, `*.secret`, `*.local`, `.env`.
- Resolve secrets at runtime from env vars or a system keychain (1Password CLI, `security` on macOS, GNOME keyring, etc.).
- The example yml uses `${VAR}` placeholders — these are not magic; your shell or your connector script has to actually expand them.

## Writing your own connector

Each connector is a folder with a `README.md` and optionally a fetch script. The protocols don't import code from these folders — they just read `connectors.yml` to know what's available.

Minimal new connector:

```bash
mkdir -p connectors/myservice
cat > connectors/myservice/README.md <<EOF
# myservice connector
Role: <what signal this provides>
Pattern: flatfile
Fetch: <cron entry / manual script>
EOF

cat > connectors/myservice/fetch.sh <<'EOF'
#!/usr/bin/env bash
mkdir -p "$(dirname "$0")/data"
curl ... > "$(dirname "$0")/data/dump-$(date +%F).json"
EOF
chmod +x connectors/myservice/fetch.sh
```

Then in your local `connectors.yml`:

```yaml
myservice:
  enabled: true
  type: flatfile
  role: <what-signal-this-provides>
  options:
    path: connectors/myservice/data/
    glob: 'dump-*.json'
```

The mentor will see `myservice` listed in `CONFIG.md` under connectors and know it can grep for data there during WEEKLY_REVIEW Phase 1.
