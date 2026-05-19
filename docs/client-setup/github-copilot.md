# GitHub Copilot (VS Code) setup

Run Trellis inside VS Code with Copilot Chat as the mentor.

## Setup

1. Open your notebook folder as a VS Code workspace.
2. Create `.github/copilot-instructions.md` at the notebook root:

   ```markdown
   # Mentor Team — Copilot Instructions

   You are the mentor team for the user, running under the Trellis framework.

   Your operating manual is `framework/PROTOCOLS.md`. Your constitution is `framework/FIRST_PRINCIPLES.md`. Your configuration is `CONFIG.md`.

   At the start of every chat:
     1. Read `CONFIG.md`.
     2. Identify the named protocol from the user's trigger phrase ("session on X", "weekly review", "season review", "refresh mentors").
     3. Run that protocol exactly as specified. Pause at every checkpoint.
     4. Run the critical-thinking pass.
     5. Write journal artifacts back to disk using the edit tools.

   Path discovery: notebook root = workspace root. All paths in `framework/PROTOCOLS.md` are relative to it (substitute `[ROOT]` → workspace root).

   Use parallel tool calls when invoking multiple independent operations (e.g., spawning per-domain mentor agents in WEEKLY_REVIEW Phase 2).
   ```

3. (Optional) Per-domain instruction files. Create `.github/instructions/<domain>.instructions.md` with `applyTo: "mentors/<domain>/**"` frontmatter to give the model domain-specific framing whenever it works in that folder.

## How sessions flow

- Open Copilot Chat in agent mode.
- Type: *"Let's do a session on writing."*
- Copilot reads the relevant `mentors/writing/` files, runs DOMAIN_SESSION.
- At session end, it proposes edits to `sessions/<date>.md`, `log.md`, etc., as standard VS Code edit proposals. You accept or reject.

## MCP connectors

Copilot in recent VS Code versions supports MCP servers. Configure them in your VS Code settings or `.vscode/mcp.json`:

```json
{
  "servers": {
    "todoist": {
      "type": "stdio",
      "command": "uvx",
      "args": ["mcp-server-todoist"]
    }
  }
}
```

## Caveats

- Copilot's chat history per file is more ephemeral than Claude Desktop / Code. The protocols' insistence on writing journal artifacts to disk every session is doubly important here — without it, you lose continuity.
- If you have a long weekly review, consider asking Copilot to write intermediate state (Phase 1 brief, Phase 2 mentor reports) into a scratch file in `coordinator_history/` so you don't lose it if the chat resets.

## Recommended models

- For weekly reviews and high-stakes work: pick the strongest model your Copilot subscription gives access to.
- For routine sessions: any model is fine.
