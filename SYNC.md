# SYNC.md — keeping Trellis in step with its reference notebook

Trellis is the public generalization of one live notebook — the **reference instance** (PA). Every enhancement lands in PA first, runs for real for at least one weekly review, and is then ported here with the personal content generalized. This file is the porting contract: what maps to what, how to generalize it, and what must survive a port.

**Rule:** after any change to a PA framework file (`.claude/skills/**`, `mentors/PROTOCOLS.md`, `mentors/_template/**`, `FIRST_PRINCIPLES.md`, `tools/**`, or the header/format of a fold file), the Trellis counterpart below is updated before the next weekly review. On the PA side, `PROTOCOLS.md → TRELLIS_SYNC` is the trigger; the weekly review prints *Trellis sync pending* when framework files changed since the last review.

## File mapping

| Reference notebook (PA) | Trellis | Notes |
|---|---|---|
| `.claude/skills/weekly-review/SKILL.md` | `.claude/skills/weekly-review/SKILL.md` | Coordinator procedure. Trellis adds PROTOCOL_MODE, the first-review light path, CONFIG time constants, the optional `scripts/sync.sh` commit; drops PA's Trellis-sync check. |
| `.claude/skills/weekly-review/mentor_prompt.md` | `.claude/skills/weekly-review/mentor_prompt.md` | Mentor agent instructions — near-verbatim after substitutions. intel.md stays "IN FULL — every review". |
| `.claude/skills/domain-session/SKILL.md` | `.claude/skills/domain-session/SKILL.md` | Trellis adds the skill preamble, the "change the instrument" sentence (step 9), the AI-proof elaboration (step 10), the optional commit (11i). |
| `mentors/PROTOCOLS.md` | `core/PROTOCOLS.md` | Trellis adds INTAKE, "Keeping your notebook in git", CONFIG references, PROTOCOL_MODE, "Keeping Trellis in sync". PA's TRELLIS_SYNC protocol is not ported — this file replaces it. MODEL ROUTING is tier-based here: PA's concrete model/provider/reasoning binding becomes `CONFIG.md → PLANNING_MODEL` + a pointer to `docs/client-setup/`; DOMAIN OWNERSHIP ports near-verbatim as procedure text. |
| `FIRST_PRINCIPLES.md` | `core/FIRST_PRINCIPLES.md` | Mirror. Amendments only with the principal's decision. |
| `mentors/_template/*` | `templates/domain/*` | Domain scaffold: current_focus (Stance / Position / fold), log, done_topics, intel, curriculum, README (season + year archive templates). |
| `mentors/MEMORY.md` — header + section skeleton | `core/MEMORY.md.template` | Fold line, budget line, write rule, `RULES` / `FACTS` / `NEVER-REPEAT` / `ASKS — open`, `## Stories added`. Empty-seeded; content never ported. |
| `mentors/prateek.md` — section names + fold | `core/profile.md.template` | Sections only, never content. Installed as `mentors/profile.md`; rotation target `mentors/profile_history/`. |
| `mentors/coordinator_state.md` — shape | `core/coordinator_state.md.template` | Sections incl. `## Active Watches — for the next review only`, `## Team board`, the fold, the DOMAIN OWNERSHIP scope limit (decisions and pointers, never domain teaching material); history to `mentors/coordinator_history/`. |
| `mentors/season_current.md` — shape | `core/season_current.md.template` | Sections incl. `## Upcoming dates & disruptions (next 6 weeks)`, External Schedule Anchors, the fold. |
| PA's `CLAUDE.md` — routing/ownership paragraph | the `CLAUDE.md` heredoc in `scripts/init.sh` | The scaffolded notebook's entry point. Port the *behaviour* (planning is judgment work; mentors own their domains; the coordinator challenges but never authors) with `PLANNING_MODEL` in place of a named model. |
| PA's runtime bindings (`.claude/agents/*`, Hermes session/delegation facts) | `docs/client-setup/<client>.md` | Client pages, never the framework files. PA's three subagent definitions are **not** ported as templates; the Claude Code page describes per-agent `model:` + the `tools:` allowlist instead, and `hermes.md` documents session-inherited models, compaction and the absent read-only file toolset. |
| `tools/pa-sync.sh` | `scripts/sync.sh` | Optional commit wrapper; never blocks a protocol. |

## Generalization rules

- `Prateek` → `{{USER_NAME}}`; he/him/his → they/them/their. `[PA]` → `[ROOT]`.
- `prateek.md` → `profile.md` (lives at `mentors/profile.md`); `prateek_history/` → `profile_history/`.
- Path discovery: `[ROOT]` = the directory containing `CLAUDE.md` and `mentors/`; fallback `find ~ /sessions -maxdepth 6 -name MEMORY.md -path '*/mentors/*' -not -path '*/.git/*' 2>/dev/null | head -1` → strip `/mentors/MEMORY.md`. (PA says "the directory containing `FIRST_PRINCIPLES.md`"; in a Trellis notebook the principles live at `framework/FIRST_PRINCIPLES.md`.)
- `Todoist` and its verbs (`find-tasks-by-date`, `find-completed-tasks`, `find-comments`) → "your task connector" (configured in `CONFIG.md`), described generically but keeping the three-call structure: tasks due/completed in the past 7 days · comments on each · overdue.
- `AskUserQuestion` keeps its name; say "(or the client's question/prompt tool)" once.
- Domain-specific examples (named teachers, courses, ragas, exams, companies, people) → neutral examples or removed. Structural learnings that became RULES in PA are ported as procedure text, never as the principal's story.
- Time constants → `[TIME_FLOOR_PER_DOMAIN]` / `[TIME_CEILING_PER_DAY]` from `CONFIG.md`. Per-instance baselines ("W9 baseline: 8") are dropped.
- Model names, providers and reasoning levels → `CONFIG.md → PLANNING_MODEL` / `PLANNING_EFFORT` and capability tiers ("judgment" vs collection/formatting). A concrete binding belongs in `docs/client-setup/<client>.md`, never in a framework file — the framework must not age out when a model is renamed.
- PA assumes its notebook is a git repo; Trellis git is optional. A `git status` guard ports as "if your notebook is in git, …" and must never gate a protocol step.
- Dates inside procedure text are dropped; `## Stories added after <date>` → `## Stories added`. CHANGELOG / ARCHITECTURE may say "(fold convention adopted 2026-09-08)".
- `[PA]/../.auto-memory/MEMORY.md` → "the client's auto-memory index, if the client exposes one (Cowork: `[ROOT]/../.auto-memory/MEMORY.md`)".
- Use only the `{{…}}` placeholders that `scripts/init.sh`'s `substitute` function knows (`{{USER_NAME}}`, `{{WORKSPACE_NAME}}`, `{{TIMEZONE}}`, `{{NOTEBOOK_ROOT}}`, `{{CLIENT}}`, the season / rhythm / comm / `{{PROTOCOL_MODE}}` keys).

## Trellis-only blocks that must survive a port

PROTOCOL_MODE (`checkpoints` / `automated`) · the first-review light path (weeks 1–2) · INTAKE · MENTOR_REFRESH wording (cadence only — intel is always read in full) · connectors + `CONFIG.md` placeholders · "Keeping your notebook in git" + `scripts/sync.sh` · the skill preambles · WIKI_BRIDGE references · the DRIFT REPORT's FACTS-reconciliation line · the client-agnostic tier wording in MODEL ROUTING (no model names) · the "if your notebook is in git" conditional on every git guard.

## How to port

1. Read the PA file in full; diff it against the Trellis counterpart.
2. Apply the substitutions above; neutralize every personal example.
3. Re-insert the Trellis-only blocks listed above.
4. If a fold file's header (budget, write rule) or section skeleton changed, mirror it in `core/*.template` / `templates/domain/*`.
5. Fresh `scripts/init.sh --notebook <tmpdir>`, then `scripts/validate.sh --notebook <tmpdir>` passes.
6. `grep -ri prateek --exclude=SYNC.md .` returns nothing except the GitHub Pages URL in `README.md`.
7. Add a `CHANGELOG.md` line; commit on a branch.

## Drift signal (rough size, not a gate)

```bash
PA="$HOME/Documents/Claude/Projects/Personal Assistant"; TR="$HOME/Desktop/Personal/Projects/Assistant/Trellis"
for pair in ".claude/skills/weekly-review/SKILL.md:.claude/skills/weekly-review/SKILL.md" \
            ".claude/skills/weekly-review/mentor_prompt.md:.claude/skills/weekly-review/mentor_prompt.md" \
            ".claude/skills/domain-session/SKILL.md:.claude/skills/domain-session/SKILL.md" \
            "mentors/PROTOCOLS.md:core/PROTOCOLS.md" "FIRST_PRINCIPLES.md:core/FIRST_PRINCIPLES.md"; do
  printf '%5s  %s\n' "$(diff <(sed -e 's/Prateek/{{USER_NAME}}/g' -e 's/\[PA\]/[ROOT]/g' -e 's/prateek\.md/profile.md/g' "$PA/${pair%%:*}") "$TR/${pair##*:}" | grep -c '^[<>]')" "${pair##*:}"
done
```

The number is changed-lines-after-substitution per file — a size-of-drift indicator (Trellis-only blocks always contribute some), not a pass/fail gate. A jump between two syncs means something landed in PA that has not been ported.
