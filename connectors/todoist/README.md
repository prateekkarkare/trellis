# Todoist connector

**Role**: primary task-completion signal for `WEEKLY_REVIEW`.

Todoist (or any task manager that supports MCP) is the highest-leverage connector to wire up first. The weekly review's signal-detection logic was designed around it: scheduled vs done, comments on tasks, reschedule patterns.

## Setup (MCP path — preferred)

1. Install an MCP server for Todoist. As of writing, community options exist on the MCP registry; pick the one your client supports.
2. Register it with your LLM client (Claude Desktop config, Claude Code `.mcp.json`, etc.).
3. Edit `connectors/connectors.yml`:
   ```yaml
   todoist:
     enabled: true
     type: mcp
     mcp_server: todoist
   ```
4. Test by saying to your mentor: *"Pull my Todoist tasks from the past 7 days."* If the model can call the tool, you're done.

## Setup (flat-file fallback)

If MCP isn't an option, dump Todoist data nightly to `connectors/todoist/data/`. A minimal script:

```bash
# connectors/todoist/fetch.sh — runs nightly
curl -s -H "Authorization: Bearer $TODOIST_API_KEY" \
  "https://api.todoist.com/rest/v2/tasks" \
  > "$(dirname "$0")/data/tasks-$(date +%F).json"
```

Then in `connectors.yml`:

```yaml
todoist:
  enabled: true
  type: flatfile
  options:
    path: connectors/todoist/data/
    glob: 'tasks-*.json'
```

## What WEEKLY_REVIEW reads (in order)

1. **Past week tasks**: every task with a due date in the past 7 days (completed or not).
2. **Comments on every task above** — verbatim. These are your voice. Most valuable signal in the system.
3. **Overdue tasks**: anything still open and past due. 1 day = friction; 3+ days = avoidance; 7+ days = structural barrier.

See `core/PROTOCOLS.md` → `WEEKLY_REVIEW` → Phase 1 → "TODOIST" for the full read sequence.

## Cost / rate-limits

The MCP path is generally OK for once-a-week pulls. The flat-file path is bulletproof — runs on your schedule, never throttles. If you do per-day pulls into flat files, you can grep across them and reconstruct any week trivially.
