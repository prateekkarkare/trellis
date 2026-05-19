# ChatGPT Projects setup

ChatGPT Projects are similar to Claude Desktop Projects. Less ergonomic for file writes, more accessible to non-developer users.

## Setup

1. In ChatGPT, create a new Project. Name it your `WORKSPACE_NAME`.
2. Upload your notebook as Project files. (ChatGPT Projects accept uploaded files as persistent context.)
   - Upload `CONFIG.md`, `profile.md`.
   - Upload everything under `framework/`.
   - Upload everything under `mentors/`.
   - You'll need to re-upload after significant changes — Project files don't auto-sync.
3. In Project Instructions, paste:

   ```
   You are the mentor team for the user, running under the Trellis framework.

   Your operating manual is the uploaded `framework/PROTOCOLS.md`. Your constitution is `framework/FIRST_PRINCIPLES.md`. Your configuration is `CONFIG.md`.

   At the start of every chat:
     1. Read CONFIG.md.
     2. Identify the named protocol from the user's trigger phrase.
     3. Run that protocol exactly as specified. Honor every checkpoint.
     4. Run the critical-thinking pass.
     5. At session end, OUTPUT the file diffs the protocol specifies — the user will commit them by hand.

   Path discovery: treat the uploaded files as the notebook root. Substitute `[ROOT]` → `.` in the protocols.
   ```

## How sessions flow

- New chat in the Project: *"Let's do a session on writing."*
- ChatGPT reads the uploaded files, runs DOMAIN_SESSION.
- At session end, ChatGPT prints the proposed journal entries as code blocks.
- **You** copy-paste those into your local notebook and commit.

This is the highest-friction client of the four. If you want autonomous writes, use Claude Code or Copilot.

## Connectors

ChatGPT supports custom GPTs with **Actions** (OpenAPI-defined external calls). You can wire a Todoist action into the GPT manually. Less ergonomic than MCP but it works.

## Caveats

- Project files are versioned only insofar as you re-upload them. Treat each session's writes as instructions to update your local files, not as the canonical write.
- The "no autonomous writes" constraint actually maps cleanly to Trellis's principle P2 (the user writes by talking) and P3 (the mentor writes the files) — but here, the "writing" is mediated through copy-paste.
- Memory features in ChatGPT can conflict with the protocol-defined memory model. Consider disabling ChatGPT Memory for this Project — your `profile.md` is the canonical memory.

## Recommended models

- GPT-4o or better for routine work.
- The strongest reasoning model available for weekly reviews and high-stakes domains.
