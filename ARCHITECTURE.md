# Architecture

A one-page tour of how Trellis is put together. For the deeper version: [`core/FIRST_PRINCIPLES.md`](core/FIRST_PRINCIPLES.md). For the operating spec: [`core/PROTOCOLS.md`](core/PROTOCOLS.md). Trellis tracks a live reference notebook — see [`SYNC.md`](SYNC.md).

## The three layers

```
LAYER 3 — Client
  Claude Cowork / Claude Code / any file-reading assistant
        │  reads / writes markdown
        ▼
LAYER 2 — Notebook (your personal data, your private repo)
  CLAUDE.md          — entry point the client auto-loads
  CONFIG.md          — your parameters (rhythm, connector, PROTOCOL_MODE)
  framework/         — personalized copies of the layer-1 protocol docs
  .claude/skills/
    ├── weekly-review/   SKILL.md (coordinator) + mentor_prompt.md (each mentor agent)
    └── domain-session/  SKILL.md
  mentors/
    ├── MEMORY.md            — rules · facts · never-repeat · asks  (fold file)
    ├── profile.md           — behavioral profile                   (fold file)
    ├── season_current.md    ┐                                       (fold file)
    ├── coordinator_state.md │  coordinator state, incl. Team board  (fold file)
    ├── cross_domain.md      ┘
    ├── profile_history/  coordinator_history/   — overflow
    └── <domain>/
        ├── current_focus.md — Stance · Position · In progress …   (fold file)
        ├── curriculum.md    ┐
        ├── done_topics.md   │
        ├── intel.md         │  per-domain notebook
        ├── log.md           │
        ├── sessions/        │
        └── archive/         ┘  season_<N>.md · year_<YYYY>.md
        │  generated from
        ▼
LAYER 1 — Framework (Trellis distribution, this repo)
  core/
    ├── FIRST_PRINCIPLES.md   — the constitution
    ├── PROTOCOLS.md          — INTAKE + rare protocols + FILE KINDS + skill stubs
    ├── MEMORY.md.template    — the always-read memory file (empty-seeded, folded)
    ├── WIKI_BRIDGE.md        — optional knowledge-base hook
    └── *.template            — parameterized starter files
  .claude/skills/            — weekly-review (SKILL.md + mentor_prompt.md) + domain-session
  templates/domain/           — scaffold per new mentor
  examples/example_domain/    — worked example
  connectors/                 — adapter stubs
  scripts/                    — init.sh, add-domain.sh, validate.sh, sync.sh
  docs/                       — guides per client / topic
  SYNC.md                     — how this repo tracks the reference notebook
```

## The fold

Five files — `MEMORY.md`, `profile.md`, `coordinator_state.md`, `season_current.md`, every `<domain>/current_focus.md` — carry one line, `## ── HISTORY (on demand; agents do not read past this line) ──`. Current state lives above it (short entries, no dated sections); every story and superseded state lives below it, verbatim. Agents read to the fold (`sed -n '1,/^## ── HISTORY/p' <file>`) and fetch a story by ID only when a check fails. Each header states an above-the-fold budget; the weekly review's BUDGET CHECK measures the five top halves, and an overrun is fixed by moving content below the fold — never deleting (P6). That keeps the always-read set bounded as the notebook ages, with no database and nothing lost.

| Kind | Files | Write operation | Readers take |
|---|---|---|---|
| **Ledgers** | `MEMORY.md` (RULES / FACTS / NEVER-REPEAT / ASKS), the laws in `profile.md`, `done_topics.md` | append a line; edit an entry in place by ID; retire = move below the fold | everything above the fold |
| **Working memory** | `current_focus.md`, `coordinator_state.md`, `season_current.md`, `WEEK_BRIEFING.md` | replace the affected `## section` in place; the reason goes to `log.md` | everything above the fold |
| **Logs** | `log.md`, `TRACKER.md`, `*_history/`, the dated sections below every fold | append only | the tail (last 2 log entries; the THIS WEEK block) |

## How a session flows (end-to-end)

```
1. User → Client     "let's do a session on writing"
2. Client → LLM      CLAUDE.md + the message; DOMAIN_SESSION skill loads
3. LLM (mentor)
   d. PREPARE (all fold files read above the fold only):
      - mentors/writing/done_topics.md         (never reassign work)
      - mentors/MEMORY.md                      (rules · facts · never-repeat · asks)
      - mentors/profile.md, season_current.md
      - mentors/writing/current_focus.md       (adopt the Stance; Position → section)
      - mentors/writing/curriculum.md          (the named section + lookahead)
      - mentors/writing/log.md                 (last 2 entries)
      - mentors/writing/intel.md               (in full, every session)
   e. COACH: conversation; inline critical thinking; ~70% edge
   f. JOURNAL: sessions/<date>.md · log.md line · done_topics row ·
      current_focus sections replaced in place · MEMORY.md write-back ·
      budget check (current_focus ≤ 5 KB above the fold) · optional commit
```

## How a weekly review flows

```
Phase 1  GATHER (coordinator, no agents)
  connector: due/completed 7d → comments → overdue · TRACKER THIS WEEK block ·
  files touched in 7 days · MEMORY above the fold (ask ages +1) ·
  profile / season / coordinator_state above the fold (Team board) → WEEK_BRIEF
⏸ Checkpoint 1 — signal brief (AskUserQuestion; skipped in PROTOCOL_MODE=automated)
Phase 2  PARALLEL MENTORS — one Agent per active domain (judgment role: PLANNING_MODEL),
  a short call: "read mentor_prompt.md, here is the WEEK_BRIEF, you are read-only"
  → each reads MEMORY first, intel in full, its own slices → PREFLIGHT · THREE_MOVES ·
  NEXT_WEEK_GOALS (+ rationale: / how:) · VALUE_CHECK · TEAM_LINE · FOCUS_UPDATE ·
  NEW_LESSON/NEW_FACT · LOG_ENTRY
Phase 3  SYNTHESIS — time/slot/cross-domain; ASKS escalation (Age ≥ 3 = challenge);
  RELEVANCE CHALLENGE: coordinator questions a goal's rationale, mentor answers
  keep/revise/withdraw (one round, coordinator may defer or block but never author);
  coordinator_state rewritten in place (Team board) → VERIFIER: a fresh-context
  Agent that did not write the plan returns SELF-CHECK; every defect fixed first
⏸ Checkpoint 2 — plan + Self-check (count the user's corrections; unresolved
  disagreements shown with both positions — the user decides)
Phase 4  WRITES by file kind — connector + WEEK_BRIEFING (HOW copied from the mentor) ·
  log.md (append) · done_topics · current_focus (FOCUS_UPDATE) · DRIFT_CHECK ·
  MEMORY.md (by ID) · TRACKER · season_current · curriculum ·
  profile.md (below fold; promote ≥ 2 wk)
  → CORRECTION COUNT (CP2 corrections · verifier caught · relevance · routing)
  → BUDGET CHECK
Phase 5  PRESENT — phone-readable; value is the headline, not completion
```

**Who owns what.** The mentors own their domains (assessment, method, curriculum, research, the recommendation); the coordinator owns evidence, capacity, sequencing, the checkpoints and the writes. Both can run on the same strong model — capability is not authority, and `framework/PROTOCOLS.md → DOMAIN OWNERSHIP` is what stops the coordinator accumulating the mentors' knowledge over years. `docs/client-setup/` covers binding a role to a model in your client.

## The pyramid (P8)

Higher layers are mentor-compressed from lower; never parallel-written.

```
sessions/<date>.md        ← full prose, one per session
        ↓
log.md                    ← one line per session; readers take the last 2
        ↓
archive/season_<N>.md     ← one synthesis per season (from log.md)
        ↓
archive/year_<YYYY>.md    ← one year-in-review (from the season archives)
```

With the fold, this bounds per-session read cost as the system ages: a mentor reads the log tail, the named curriculum section, and everything above five folds — never the whole notebook.

## Architecture diagram

A React component version lives at [`docs/diagrams/mentor_architecture_diagram.jsx`](docs/diagrams/mentor_architecture_diagram.jsx).
