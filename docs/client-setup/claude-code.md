# Claude Code setup

Claude Code is the easiest path for autonomous read+write file workflows. The mentor can update your notebook directly.

## Setup

1. From the parent dir of your notebook:
   ```bash
   cd /path/to/parent
   claude
   ```
   Or `cd` into the notebook itself and run `claude`.

2. Create an `AGENTS.md` at the notebook root with this content:

   ```markdown
   # Mentor Team — AGENTS.md

   You are the mentor team for the user, running under the Trellis framework.

   Your operating manual is `framework/PROTOCOLS.md`. Your constitution is `framework/FIRST_PRINCIPLES.md`. Your configuration is `CONFIG.md`.

   At the start of every interaction:
     1. Read CONFIG.md.
     2. Identify the named protocol from the user's trigger phrase.
     3. Run that protocol exactly as specified. Honor every checkpoint.
     4. Run the critical-thinking pass (signal triage, devil's advocate, historical pattern gate).
     5. At session end, write all journal artifacts to disk.

   Path discovery: the notebook root is the directory containing this file. Treat all paths in `framework/PROTOCOLS.md` as relative to the notebook root (substitute `[ROOT]` → `.`).

   When invoking subagents (e.g., one per active domain in WEEKLY_REVIEW Phase 2), spawn them in parallel — single message, multiple Task tool calls.
   ```

3. (Optional) Add `.mcp.json` to configure connectors. Example:

   ```json
   {
     "mcpServers": {
       "todoist": {
         "command": "uvx",
         "args": ["mcp-server-todoist"],
         "env": { "TODOIST_API_KEY": "${TODOIST_API_KEY}" }
       }
     }
   }
   ```

## How sessions flow

- You're in a Claude Code REPL session in your notebook dir.
- You say: *"Let's do a session on fitness."*
- Claude reads `mentors/fitness/`, runs DOMAIN_SESSION.
- At session end, Claude calls Edit/Write tools to update `sessions/<date>.md`, `log.md`, `done_topics.md`, `current_focus.md`. You review the diffs.
- (Optional) Auto-commit on session end: add a slash-command `/journal-and-sync` that runs the JOURNAL step plus `git add -A && git commit -m "session: <domain>"`.

## Parallel mentor agents in WEEKLY_REVIEW

Claude Code's `Task` tool supports parallel subagent invocation. In WEEKLY_REVIEW Phase 2, the coordinator should spawn one Task per active domain in a single message — they run in parallel and report back together. The protocol is written to take advantage of this.

## Recommended models

- **/model opus** (or strongest available) for weekly reviews and high-stakes domain sessions.
- **/model sonnet** for routine sessions to save cost.

You can switch models mid-session with `/model`.
