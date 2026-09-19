# Hermes Agent setup

[Hermes Agent](https://hermes-agent.nousresearch.com/docs/) is a provider-agnostic terminal/desktop agent. It reads a root `CLAUDE.md` (or `AGENTS.md`) as project instructions, has read/write file tools, and can fan out subagents with `delegate_task` — enough to run the whole framework.

## Setup

1. Install Hermes and sign in to whichever provider you intend to use, then `cd` into your notebook:
   ```bash
   cd /path/to/your-notebook
   hermes
   ```

2. The scaffolded `CLAUDE.md` at the notebook root is picked up automatically — it is the same entry point Claude Cowork uses, so there is nothing extra to paste. `AGENTS.md` works too if you prefer that name.

3. (Optional) Wire a task connector as an MCP server — `hermes mcp` manages them. See `docs/connectors.md` for what the protocols expect from a connector.

## How sessions flow

- You say *"weekly review"* or *"let's do a session on fitness"*; the matching skill text in `.claude/skills/` is the procedure.
- The agent reads the notebook, runs the protocol, pauses at the checkpoints (`CONFIG.md → PROTOCOL_MODE = checkpoints`), and writes the files at the end.
- Because Hermes has real write tools, review the diffs — `git status` / `git diff` in the notebook after a review is the cheapest audit you have.

## Model routing — the one thing to get right

`framework/PROTOCOLS.md → MODEL ROUTING` asks for the judgment roles (mentor next-step proposals, coordinator reconciliation, verifier) to run on `CONFIG.md → PLANNING_MODEL`. In Hermes:

- **`delegate_task` has no per-child model field.** Children inherit the parent session's model, provider and reasoning level unless the profile-wide `delegation.model` / `delegation.provider` / `delegation.reasoning_effort` keys are set.
- **So bind the session, not the agent.** Start the review in a session already on your planning model and the mentors inherit it:
  ```bash
  hermes chat --provider <provider> --model <model> --reasoning <level>
  ```
  or, in a running session, `/model <provider>:<model>` then `/reasoning <level>`. Check `hermes --help` and `hermes chat --help` for the flags your build exposes.
- **Confirm it before Phase 2, don't assume it.** `model.default` in `~/.hermes/config.yaml` is the *saved* default for a fresh launch; an explicit session selection overrides it, and a fresh launch elsewhere will not have it. Step 1.4 of the weekly review asks you to record the live model — do that rather than trusting the config file.
- Changing `model.default` or `delegation.*` to get this effect is a bigger hammer than you need: those are profile-wide and affect every other session, cron job and messaging channel.

## Two runtime facts worth knowing

- **Usable context < advertised window.** Providers cap input below the headline figure, and Hermes compacts a conversation at `compression.threshold` (a fraction of the resolved window, default 0.5) — for children too. If a mentor run compacts mid-report, that is lost evidence: record it as a coverage note rather than treating the report as complete. Some models also have opt-in large-window variants; leave them off until a measured review actually needs one.
- **There is no read-only file toolset.** Hermes's `file` toolset bundles read *and* write tools, so a delegated mentor technically can write. The framework handles this with instructions plus verification: the Phase 2 prompt tells workers not to write, and Step 3.4b re-runs `git status --short` to catch it if they did. Keep your notebook in git and that check is meaningful; without git you are trusting the instruction alone.

## Reliability notes

- `hermes chat --oneshot --query-file <file>` is the bounded, scriptable form — useful for a single mentor consult or a verifier pass without an interactive session.
- If your provider is rate-limited or logged out, stop and say so. A silent fallback to a weaker model produces a plan that *looks* like a full review; the framework asks you to disclose the tier you actually used (Step 1.4, and the routing field on the Step 4h line).
- Hermes persists sessions, so a review interrupted mid-write can be resumed — reconcile against the write receipt rather than re-running every write.
