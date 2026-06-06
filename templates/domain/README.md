# Mentor Template

Canonical scaffold for a new domain. The mentor system is a **mentor's notebook** (see `/FIRST_PRINCIPLES.md` P9) — not a wiki. This template ships only markdown pages — no YAML, no JSONL, no CLIs in the loop.

To create a new domain:

```bash
# Copy the template (replace "painting" with the domain name)
cp -r mentors/_template mentors/painting

# Register the domain in mentors/season_current.md (manual)
# Have the painting mentor populate current_focus.md and curriculum.md in conversation.
```

## First conversation (mentor intake)

A freshly created domain starts in **needs-intake** state: `current_focus.md` has no real phase yet. Before the first working session, the mentor runs **INTAKE Part B** (see `PROTOCOLS.md`) — its own first session with the user: why this domain, an honest baseline (which seeds `done_topics.md` so finished work is never reassigned), how they want to be coached *here*, the domain-specific constraints, a mirror, one real win, and a sign-off.

The questions are **yours to choose as the domain expert.** Seed a few below that a real mentor in this field would always ask a new student; the mentor generates the rest live. Replace these examples with ones that fit `<domain>`:

- <e.g. "What have you already tried here, and what made it stick or fall apart?">
- <e.g. a domain-specific constraint question — injuries (fitness), instrument owned (music), risk tolerance (finances)>
- <e.g. "What does a real win here look like 90 days out?">
- <e.g. "How do you best learn this — by doing, theory-first, or by example?">

Once Part B is done, `current_focus.md` leaves needs-intake state and normal `DOMAIN_SESSION`s begin.

## Files in this template (all plain markdown)

| File | Purpose | Writer |
|---|---|---|
| `curriculum.md` | Vision, phases, milestones, practice cadence, real-world stakes, cross-domain hooks. Evolves slowly. | mentor (free edits) |
| `done_topics.md` | **The catalog.** One row per completed topic. Read at session start, appended at session end. The P1 fix lives here. | mentor (free edits) |
| `current_focus.md` | Mentor's working memory: current phase, in-progress topic, next planned, calibration flags. | mentor (free edits) |
| `log.md` | Chronological **index** of session pages. One line per session, referencing `sessions/<date>.md`. Phase boundaries delimited by `## Phase <N>: <name>` headers so the mentor can read only the current phase's slice. | mentor (append only) |
| `sessions/` | One markdown page per session — the source narrative. Everything else is derived from these. | mentor (one page per session) |
| `archive/` | Boundary-time compressions: `phase_<N>_<slug>.md`, `season_<N>_<period>.md`, `year_<YYYY>.md`. Immutable once written. Lets mentors read constant-cost history regardless of how old the system is. | mentor (one file per boundary) |
| `intel.md` | Expert roster, evergreen resources, current external pulse. | mentor (free edits) |

## How the layers relate (P8: one canonical layer per granularity)

```
sessions/<date>.md          ← Layer 0: source of truth at session granularity (full prose)
     ↓ mentor-compresses at session end (JOURNAL step 11b)
log.md                       ← Layer 1: chronological index (one line per session)
     ↓ mentor-summarizes at phase boundary (DOMAIN_SESSION step 11i)
archive/phase_<N>_<slug>.md ← Layer 2: phase synthesis + per-session index
     ↓ mentor-summarizes at season end (SEASON_TRANSITION)
archive/season_<N>_<...>.md ← Layer 3: season synthesis + per-phase index
     ↓ mentor-summarizes at year end (first WEEKLY_REVIEW of new year)
archive/year_<YYYY>.md       ← Layer 4: year-in-review + per-season index
```

Aside (state, not history; bounded by construction, no rotation needed):

```
done_topics.md     ← topic-granularity catalog (P1 fix lives here)
current_focus.md   ← week/phase working memory; the `Phase` field is the boundary trigger
curriculum.md      ← concept layer (phases, milestones); evolves slowly
```

Higher chronological layers are derived from lower by the mentor's deliberate write at session/phase/season/year boundaries. They are never parallel-written, and once written they are immutable.

## Archive layer — boundary triggers and templates

### When each archive file is written

| Archive | Trigger | Written by | Source material |
|---|---|---|---|
| `archive/phase_<N>_<slug>.md` | Mentor edits the `Phase` field in `current_focus.md` (advancing to next phase) | The session mentor making the edit | The `log.md` slice from last phase header to today + session pages in that range |
| `archive/season_<N>_<period>.md` | Inside SEASON_TRANSITION, before designing next season | Domain mentor + coordinator | All phase archives in the season + season exit-criteria evaluation |
| `archive/year_<YYYY>.md` | First WEEKLY_REVIEW of a new calendar year (Phase 4) | Coordinator | All season archives that landed in that year + cross-season patterns |

### Reading discipline

Mentor reads in PREPARE:
- Always: `current_focus.md` + `done_topics.md` + `curriculum.md` + `log.md` **from the start of the current phase forward**.
- For phase-adjacent context: most recent `archive/phase_<N-1>_*.md` (one file, ~30 lines).
- On-demand only: deeper archives (season, year) when a specific historical question arises.

This keeps per-session read cost **O(current phase)** regardless of system age.

### Phase archive template

```markdown
# Phase <N>: <name>
Domain: <domain> · Period: <start_date> – <end_date> · Sessions: <count>

## Phase synthesis

2–4 paragraphs covering:
- What this phase was actually about (vs. what curriculum.md predicted)
- Calibration trajectory (difficulty trend over the phase, in prose — e.g.
  "started at 5/10, climbed to 8/10 mid-phase, settled at 7/10")
- What was harder than expected · what was easier than expected
- What carried into the next phase as an open thread

## Sessions in this phase

- YYYY-MM-DD · <topic> · Difficulty <N>/10 · `sessions/YYYY-MM-DD.md`
- ...

## Key artifacts produced

- Notebook / output / wiki concept / external contact / etc.
- ...

## Open threads carried to phase <N+1>

- <thread description>
- ...
```

### Season archive template

```markdown
# Season <N>: <theme>
Domain: <domain> · Period: <start_date> – <end_date> · Phases: <count>

## Season synthesis

2–4 paragraphs covering the season's arc: what it was meant to do, what it actually did,
the trajectory across phases, and the season's exit-criteria evaluation.

## Phases in this season

- Phase 1: <name> — <one-paragraph compression> — `archive/phase_1_<slug>.md`
- Phase 2: <name> — <one-paragraph compression> — `archive/phase_2_<slug>.md`
- ...

## Exit criteria evaluation

From season_current.md exit criteria, marked Met ✅ / Partially Met ⚠️ / Not Met ❌
with one-line reasoning each.

## Open threads carried to season <N+1>

- <thread description>
```

### Year archive template

```markdown
# Year <YYYY> in <domain>

Domain: <domain> · Seasons: <count> · Total sessions: <count>

## Year-in-review

3–5 paragraphs: the year's arc, what stuck, what was dropped, calibration drift across
the year, biggest pattern shifts in {{USER_NAME}}'s behaviour in this domain, biggest
artifacts produced.

## Seasons in this year

- Season N: <theme> — <one-paragraph compression> — `archive/season_<N>_<period>.md`
- ...

## Patterns that crossed seasons

- <pattern observation>
- ...
```

## How the operations work

From `mentors/PROTOCOLS.md`. The four operations a human mentor performs:

- **PREPARE** (DOMAIN_SESSION steps 0–10 read phase) — read done_topics.md first (P1), then curriculum.md, current_focus.md, log.md, intel.md, knowledge-store wiki references.
- **COACH** (DOMAIN_SESSION conversation) — have the session. Push back when warranted. Calibrate.
- **JOURNAL** (DOMAIN_SESSION step 11) — write the session page; update log.md, done_topics.md, current_focus.md; optionally curriculum.md and a hand-off to knowledge-store wiki; trigger SYNC.
- **AUDIT** (DRIFT_CHECK, run inside WEEKLY_REVIEW) — reconcile catalog drift, detect repeat topics, flag contradictions and staleness.

## The rule that holds everything together

> Markdown prose is the source of truth. The mentor (LLM) is the writer. The user ({{USER_NAME}}) writes by talking. There are no structured writes, no validators, no CLIs in the user-facing loop. Auto-sync (`scripts/sync.sh (optional)` via LaunchAgent) is the only background mechanism.

See `/FIRST_PRINCIPLES.md` for the full statement (P1–P9).
