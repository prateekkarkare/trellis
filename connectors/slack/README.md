# Slack connector

**Role**: work-context noise floor — what kind of week were you actually having?

Useful for: detecting work-stress weeks (signal = reduced personal-domain throughput is *contextual*, not laziness), catching multi-day on-call windows, finding moments where personal projects bled into work-time slack channels.

## Setup

1. Create a Slack app for personal use (User Token Scopes you'll want: `channels:history`, `groups:history`, `im:history` if you want DM context, `reactions:read`, `users:read`).
2. Install it to your workspace, copy the User OAuth Token.
3. Either:
   - Configure the official/community Slack MCP server (preferred), OR
   - Drop the token into your env and use the API path.

Edit `connectors/connectors.yml`:

```yaml
slack:
  enabled: true
  type: mcp
  mcp_server: slack
  options:
    channels: [eng-pager, leadership-broadcast]   # be surgical
    lookback_days: 7
    include_dms: false
    include_reactions: true
```

## Channels to consider

- **#eng-pager / on-call** — were you actually on-call this week?
- **#leadership-broadcast / company-wide** — anything big happen at work?
- **DMs with manager / co-founder** — high-signal but high-privacy; consider keeping disabled
- **Any personal-project channel** — pulled into work time?

## Privacy

This is the most sensitive connector. Recommendations:

- Default to a tight allowlist of channels (not "all channels").
- Default DMs to disabled.
- Never commit the token. Use env vars resolved at runtime.
- Consider running this with a read-only personal Slack token, not a workspace admin one.

## What the protocols use it for

- **WEEKLY_REVIEW Phase 1, signal context**: the coordinator can frame "fitness slipped 3 days" as *"during a week with 47 messages in #eng-pager between 11pm and 2am"* — which is a real explanation, not an excuse.
- **profile.md updates**: persistent work-context patterns ("Tuesdays are always the worst") get noted across reviews.
