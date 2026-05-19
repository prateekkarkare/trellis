# Architecture

A one-page tour of how Trellis is put together. For the deeper version: [`core/FIRST_PRINCIPLES.md`](core/FIRST_PRINCIPLES.md). For the operating spec: [`core/PROTOCOLS.md`](core/PROTOCOLS.md).

## The three layers

```
┌────────────────────────────────────────────────────────────────┐
│  LAYER 3 — Client                                              │
│  Claude Desktop / Claude Code / Copilot / ChatGPT / other      │
│  Drives the LLM, exposes tools, hosts the conversation.        │
└──────────────────────────┬─────────────────────────────────────┘
                           │ reads/writes markdown
                           ▼
┌────────────────────────────────────────────────────────────────┐
│  LAYER 2 — Notebook (your personal data, your private repo)    │
│                                                                 │
│   CONFIG.md         — your parameters                          │
│   profile.md        — behavioral observations                  │
│   framework/        — copies of layer 1 protocols              │
│   mentors/                                                      │
│     ├── season_current.md      ┐                               │
│     ├── coordinator_state.md   │  coordinator state            │
│     ├── cross_domain.md        ┘                               │
│     └── <domain>/                                              │
│         ├── curriculum.md      ┐                               │
│         ├── current_focus.md   │                               │
│         ├── done_topics.md     │  per-domain notebook          │
│         ├── intel.md           │                               │
│         ├── log.md             │                               │
│         ├── sessions/          │                               │
│         └── archive/           ┘                               │
└──────────────────────────┬─────────────────────────────────────┘
                           │ generated from
                           ▼
┌────────────────────────────────────────────────────────────────┐
│  LAYER 1 — Framework (Trellis distribution, this repo)         │
│                                                                 │
│   core/                                                         │
│     ├── FIRST_PRINCIPLES.md   — the constitution               │
│     ├── PROTOCOLS.md          — DOMAIN_SESSION, WEEKLY_REVIEW, │
│     │                           MENTOR_REFRESH, etc.           │
│     ├── WIKI_BRIDGE.md        — optional knowledge-base hook   │
│     └── *.template            — parameterized starter files    │
│                                                                 │
│   templates/domain/           — scaffold per new mentor        │
│   examples/example_domain/    — worked example                 │
│   connectors/                 — adapter stubs                  │
│   scripts/                    — init.sh, add-domain.sh, etc.   │
│   docs/                       — guides per client / topic      │
└────────────────────────────────────────────────────────────────┘
```

## How a session flows (end-to-end)

```
1. User → Client     "let's do a session on writing"
2. Client → LLM      sends instructions + the user's message
3. LLM (mentor)
   a. reads CONFIG.md                          (who, where, params)
   b. reads framework/PROTOCOLS.md             (the spec)
   c. identifies trigger: DOMAIN_SESSION on `writing`
   d. PREPARE:
      - reads mentors/writing/done_topics.md   (never reassign work)
      - reads mentors/writing/current_focus.md (where we left off)
      - reads mentors/writing/curriculum.md    (where we're going)
      - reads mentors/writing/log.md (current phase slice only)
      - reads mentors/writing/intel.md         (external knowledge)
      - reads profile.md                       (who the user is)
   e. COACH:
      - conversation with user
      - applies critical-thinking pass before recommending anything
   f. JOURNAL (at session end):
      - writes mentors/writing/sessions/<date>.md
      - appends to log.md
      - appends to done_topics.md
      - updates current_focus.md
      - optionally edits curriculum.md if it adapted
4. LLM → Client → User    confirms the writes, ends session
```

## How a weekly review flows

```
1. User → "weekly review"
2. Coordinator (LLM)
   Phase 1: gather signals
     - reads connectors (if configured) for completion data + comments
     - reads each active domain's log/focus
     - reads coordinator_state.md, cross_domain.md, profile.md
     - synthesizes WEEK_BRIEF
   ⏸ Checkpoint 1: user confirms the brief
   Phase 2: spawn parallel mentor agents
     - one Task per active domain (real parallelism)
     - each mentor reads its own folder + WEEK_BRIEF
     - each runs the critical-thinking pass
     - each returns a structured report
   Phase 3: synthesize
     - resolve cross-domain conflicts
     - update coordinator_state.md (high-stakes register, watches, etc.)
   ⏸ Checkpoint 2: user approves the plan
   Phase 4: write outputs
     - per-domain: update current_focus.md, log.md if a journal happened
     - update coordinator_state.md (Phase 3 step 3.5)
     - update cross_domain.md if anything new emerged
   Phase 5: present
     - brief summary + per-domain next-week plan
```

## The pyramid (P8)

Higher layers are mentor-compressed from lower; never parallel-written:

```
sessions/<date>.md        ← full prose, one per session
        ↓
log.md                    ← one line per session
        ↓
archive/phase_<N>.md      ← one synthesis per phase
        ↓
archive/season_<N>.md     ← one synthesis per season
        ↓
archive/year_<YYYY>.md    ← one year-in-review
```

This is what keeps per-session read cost bounded as the system ages.

## Architecture diagram

A React component version of the above lives at [`docs/diagrams/mentor_architecture_diagram.jsx`](docs/diagrams/mentor_architecture_diagram.jsx) — drop into any React app to render it interactively.
