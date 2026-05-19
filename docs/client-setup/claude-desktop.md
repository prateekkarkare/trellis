# Claude Desktop setup

Claude Desktop's **Projects** feature is the most ergonomic way to run Trellis.

## Setup

1. Open Claude Desktop. Create a new Project. Call it your `WORKSPACE_NAME` (e.g. "Athena Notebook").
2. In the Project's **Project knowledge** panel, add your notebook folder. Claude indexes every file in it.
3. Open the Project's **Custom instructions** and paste this:

```
You are the mentor team for the user, running under the Trellis framework.

Your operating manual is in `framework/PROTOCOLS.md`. Your constitution is `framework/FIRST_PRINCIPLES.md`. Your configuration is in `CONFIG.md`.

At the start of every interaction:
  1. Read CONFIG.md to know which user, timezone, domains, and connectors apply.
  2. Identify which named protocol the user is triggering. Common triggers:
     - "session on <domain>"  → DOMAIN_SESSION
     - "weekly review"        → WEEKLY_REVIEW
     - "season review"        → SEASON_TRANSITION
     - "refresh mentors"      → MENTOR_REFRESH
     If unclear, ask.
  3. Run the protocol exactly as specified. Honor every checkpoint — pause and ask the user before proceeding past one.
  4. Honor the critical-thinking pass (signal triage, devil's advocate, historical pattern gate). You are not a yes-man.
  5. At session end, write all journal artifacts the protocol specifies. Never skip the write step.

Path discovery: your notebook root is the Project knowledge root. Treat `framework/`, `mentors/`, `profile.md`, `CONFIG.md` as relative paths from there.
```

4. (Optional) If you have MCP connectors configured at the Claude Desktop level (Todoist, Slack, etc.), they're available to all your Projects. The mentor will use them when relevant.

## How sessions flow

- You open the Project and start a new chat: *"Let's do a session on writing."*
- Claude reads `mentors/writing/`, runs DOMAIN_SESSION.
- After the session, Claude proposes file writes back into the Project knowledge.
- **You** approve each write. (Claude Desktop doesn't write files autonomously to local disk; you commit the writes manually or use a sync helper.)

## Caveats

- Claude Desktop Projects don't yet support autonomous writes back to local files. You'll either:
  - Copy-paste the proposed journal entries back into your notebook by hand (annoying but works), OR
  - Use Claude Desktop's **MCP filesystem server** pointed at your notebook (now writes can be applied directly).

Claude Code is more frictionless if autonomous writes matter to you. See [claude-code.md](claude-code.md).

## Recommended models

- For weekly reviews and high-stakes domain sessions: use the strongest model available (Opus / Sonnet-thinking class).
- For routine domain sessions: any current Claude is fine.

You can change models per-conversation in the Project. The protocols are model-agnostic.
