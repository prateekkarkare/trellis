# Changelog

All notable changes to Trellis are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- **`mentors/MEMORY.md` — the always-read memory file (LESSONS · FACTS · ASKS).** The trust layer that makes the system *learn*: every correction becomes a one-line pre-flight RULE (LESSONS) that every mentor answers before drafting, so a week-N correction provably changes week-N+1 behaviour; binding facts + a Never-Repeat list (FACTS); and an open-ask ledger with mechanical age-based escalation (ASKS). Shipped as `core/MEMORY.md.template` (empty-seeded), created by `init.sh` and seeded at INTAKE. This is the minimum trust layer for a second user: when you correct it, it stays corrected.
- **Skills split** — `WEEKLY_REVIEW` and `DOMAIN_SESSION` (the daily/weekly procedures) are carved verbatim into `.claude/skills/weekly-review/SKILL.md` and `.claude/skills/domain-session/SKILL.md`, so they load on trigger instead of depending on the whole manual being read. `core/PROTOCOLS.md` shrank to a lean manual (preamble + INTAKE + skill stubs + the rare protocols + system upgrades). `init.sh` installs the skills into the notebook.
- **Mentor-report rigor** — mentors now emit a **PREFLIGHT** block (answer every LESSONS rule pass/fail), a **THREE_MOVES** creativity-forcing step, and a **VALUE_CHECK** (value, not completion, is the headline metric). The coordinator runs a **SELF-VERIFICATION PASS** against the plan before you see it, and a **VALIDATION GATE** rejects retrieval-only / underspecified tasks. `WEEK_BRIEFING.md` is written as the full-fidelity read surface.
- **Read-scoping (cost discipline)** — mentors read the current-phase slice of curriculum/log, skip stale intel, and read the durable core of `profile.md`, roughly halving weekly-review token cost as the notebook ages.
- **System upgrades (binding):** governance (only the principal hires mentors), curriculum-correctness, owners-for-recurring-asks, value-not-completion scoring, and a comment-response loop — folded into `core/PROTOCOLS.md`.
- **DRIFT_CHECK** gained a FACTS↔canonical-home reconciliation check and a phase-header-presence check (so log-slicing actually works).
- **`CLAUDE.md` entry point** — every scaffolded notebook now gets a root `CLAUDE.md`, the file Claude (Cowork/Projects/Code) auto-loads as its instructions when the folder is connected. Without it, Claude had no idea it was a mentor team and fell back to its generic "start" skill (a to-do dashboard). `CLAUDE.md` tells it: you are the mentor team, read `framework/PROTOCOLS.md`, run `PROTOCOL: INTAKE`, don't make a generic task list. The wizard injects the user's setup choices into a visible **Setup brief** section of this file (between `SETUP_BRIEF` markers) — replacing the old hidden `.trellis/intake-brief.md`, which agents couldn't reliably discover. `.trellis/` now holds machine state only.
- **Visual onboarding wizard** (`onboarding/index.html` + `scripts/start.sh` + `scripts/wizard_server.py`) — the front door. One command (`./scripts/start.sh`) opens a browser wizard: name your notebook, choose **where to create it** (with a live path preview), pick your mentors (with suggestions), set your **rhythm** (time budget, weekly review day, season length), choose signals. "Create my team" scaffolds the notebook + a folder per mentor + the `CLAUDE.md` setup brief, then you connect the folder to Claude Cowork and say "start my intake". No terminal questions. Python-stdlib local server (no installs); degrades to a manual-steps screen if `python3` is absent.
- **A "Rhythm" step** in the wizard gives the operational knobs a concrete home: weekly time budget, weekly review day, and season length are picked visually as *starting* values, then confirmed with you during intake (INTAKE Part A).
- **Authoritative setup guide** (`docs/quickstart.md`) — a complete, no-assumptions, Claude-Cowork walkthrough: clone → wizard → connect folder → "start my intake" → verify, plus a manual (CLI) path and a settings table showing where every knob lives.
- **`PROTOCOL: INTAKE`** — a mentor-led first-conversation protocol that front-loads, through dialogue, the baseline context the system used to take weeks to earn. Directly targets cold-start dropout. Per-mentor: **Part A (know the person)** runs once and writes `profile.md` and confirms the wizard's rhythm; **Part B (know the work)** runs per mentor — each domain expert asks its *own* domain-specific questions, seeds `done_topics.md` so finished work is never reassigned, ends with one real piece of work, and gets your sign-off. Reads the wizard's `intake-brief.md` if present. Reruns when you "hire" a new mentor later.
- **Mentor "hiring" flow** — the scaffold ships with no domains; you create them via the wizard or by talking ("hire a fitness mentor"). `scripts/add-domain.sh` marks new domains *needs-intake*.
- **Onboarding overhaul**: "what the first few weeks feel like" expectation-setting and a "how to tell it's actually working" verification block in the generated notebook README.
- Initial public release: core/, templates/, examples/, connectors/, scripts/, docs/
- `scripts/init.sh` — interactive bootstrap that personalizes the framework and creates a user notebook
- `scripts/add-domain.sh` — adds a new domain mentor from the template
- One worked example domain (`writing`) showing a populated mentor's-notebook end-to-end
- Connector stubs: Todoist, Calendar, Slack
- Client setup guides: Claude Desktop, Claude Code, GitHub Copilot, ChatGPT
- Architecture diagram (React component, rendered statically in docs)

### Changed
- **Sync is now optional/manual**, not a background daemon. The heavy `SYNC` protocol + LaunchAgent machinery was replaced by a short "Keeping your notebook in git (optional)" note; `scripts/sync.sh` remains an optional convenience wrapper. No protocol blocks on version control (keeps the P4/P5 promise). Fixed a `scripts/sync.sh (optional)` templating artifact.
- `SEASON_TRANSITION` now rotates `MEMORY.md` (retire absorbed lessons / dead facts / closed asks) alongside the profile and season archives.
- Docs (`ARCHITECTURE.md`, `docs/concepts.md`) updated for the memory layer and skills. Defined the previously-referenced-but-missing `MENTOR_REFRESH` protocol in `core/PROTOCOLS.md` (it was named in CONFIG, triggers, and `intel.md` but never specified).
- `scripts/init.sh` is a **lean, non-interactive scaffolder** — it asks nothing. It accepts optional flags (`--name`, `--notebook`, `--client`, `--domains`, and rhythm flags `--season-length` / `--review-day` / `--time-ceiling`) which the wizard passes; everything else defaults. The values it writes are *starting* values the mentor confirms at intake. Domains are only created when explicitly passed.
- Client focus narrowed to **Claude Cowork** for now — it's the one path documented end to end. Other client-setup notes remain in `docs/client-setup/` but are no longer first-class. README's "client-agnostic" section reframed as "runs on Claude Cowork."
- `PROTOCOL: WEEKLY_REVIEW` gained a documented "first review" light path: with little history (weeks 1–2) it leans on intake goals instead of inventing trends.
- `core/profile.md.template`, `core/season_current.md.template`, and `core/CONFIG.md.template` reframed around ask-now (intake-seeded) vs observe-later (mentor-filled); cadence/time placeholders are now "starting values from the wizard, confirmed at intake."
- Domain template (`templates/domain/`) starts in *needs-intake* state with a "First conversation" prompt section for domain-specific intake questions.
- README and `docs/quickstart.md` rewritten to lead with the wizard and the Cowork handoff.
