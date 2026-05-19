# Connectors

External signal sources that the mentor system can read. **All optional.** The framework runs fine without any of them — connectors enrich the signal layer of the weekly review, they're not load-bearing.

## How connectors fit in

```
┌─────────────────────────────────────────────────────────────────┐
│  WEEKLY_REVIEW Phase 1 — Coordinator Gathers                    │
│                                                                  │
│   ├─ Read mentors/, profile.md, season_current.md, etc.         │
│   └─ Read SIGNALS from configured connectors:                    │
│         · todoist     → task completion data, comments           │
│         · calendar    → locked external commitments              │
│         · slack       → work-context noise floor                 │
│         · <yours>     → anything that produces useful signal     │
└─────────────────────────────────────────────────────────────────┘
```

If a connector is unavailable when the protocol runs, **the protocol degrades gracefully** — it logs the absence and proceeds with whatever it can read. It never blocks.

## How to wire one up

There are three integration patterns, in order of preference:

1. **MCP server** (Model Context Protocol). If the service has an MCP server, point your LLM client at it and add the connector to `connectors.yml` with `type: mcp`. The mentor protocols know how to call MCP tools.
2. **Local flat-file dump.** A cron/script writes a daily export to `connectors/<service>/data/`. Simple, durable, debuggable.
3. **API at protocol time.** The mentor itself calls an API during WEEKLY_REVIEW. Use when (1) and (2) are impractical.

## Files in this folder

```
connectors/
├── README.md                    (this file)
├── connectors.example.yml       (copy to connectors.yml and edit — gitignored)
├── todoist/
│   └── README.md                (todoist-specific notes)
├── calendar/
│   └── README.md
└── slack/
    └── README.md
```

## Secrets

Never commit credentials. The `.gitignore` excludes:

- `connectors/connectors.yml` (your live config)
- `**/*.secret`
- `**/*.local`
- `**/.env`

Use whichever secret store your platform offers (1Password CLI, keychain, env vars, etc.) and resolve at protocol time. The example yml shows the shape using env-var placeholders like `${TODOIST_API_KEY}`.

## Writing your own adapter

Each connector is just a folder under `connectors/<name>/` with:

- `README.md` — what this connector provides, how to set it up, what calls it makes
- (optional) `fetch.sh` / `fetch.py` — pull data into `data/` for the flat-file pattern
- (optional) `cron.example` — sample schedule entry

The mentor protocols don't import code from these folders. They just read `connectors.yml` to know what's available and how to talk to it.
