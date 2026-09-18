# Concepts

The minimum mental model for understanding why Trellis is shaped the way it is.

If you want the deeper version: [`core/FIRST_PRINCIPLES.md`](../core/FIRST_PRINCIPLES.md) is the constitution; this doc is the friendly tour.

---

## The mentor's-notebook metaphor

A good human mentor working with a long-term student keeps a folder per student:

- a topics-covered list (*"we did this already, don't reassign it"*),
- a current-focus sheet (*"this is what we're working on this month"*),
- a stack of session journals (*"here's what actually happened in each meeting"*),
- a curriculum sketch (*"this is roughly where we're going"*).

**Before each meeting**, they skim the relevant pages. **During** the meeting, they coach. **After** the meeting, they jot a session note and update the topics-covered list.

Trellis is exactly this, but the mentor is an LLM and the folder is markdown files in git. The user writes by talking. The mentor writes the files.

That's the whole idea.

---

## The four operations

Every protocol in the system is a specialization of four basic operations:

| Operation | When | What |
|---|---|---|
| **PREPARE** | Before a session | Read MEMORY, done_topics, current_focus, the named curriculum section, the log tail, intel — fold files above the fold only. Most importantly: don't propose work that's already done. |
| **COACH** | During | Have the conversation. Push back when warranted. Calibrate difficulty. |
| **JOURNAL** | After | Write the session page. Update the catalog. Update the focus sheet. Edit the curriculum if it shifted. |
| **AUDIT** | Periodically | Re-read the folder for drift, contradictions, stale claims. Happens inside the weekly review. |

Named protocols in `core/PROTOCOLS.md` (INTAKE, DOMAIN_SESSION, WEEKLY_REVIEW, MENTOR_REFRESH, SEASON_TRANSITION, DRIFT_CHECK) are these four operations specialized to different cadences and scopes. The two high-frequency ones (DOMAIN_SESSION, WEEKLY_REVIEW) load their full steps from `.claude/skills/`; the weekly review's mentor agents load only `.claude/skills/weekly-review/mentor_prompt.md`.

---

## The layer pyramid (P8)

One canonical layer per granularity. Higher layers are mentor-compressed from lower; never written in parallel.

```
sessions/<date>.md        ← session granularity     (full prose)
        ↓ mentor compresses at session end
log.md                    ← chronological index     (one line per session; readers take the last 2)
        ↓ mentor summarizes at season boundary, from log.md
archive/season_<N>.md     ← season synthesis
        ↓ mentor summarizes at year boundary
archive/year_<YYYY>.md    ← year-in-review
```

Aside (state, not history — bounded by construction):

```
done_topics.md     ← topic-granularity catalog (the "don't repeat work" rule)
current_focus.md   ← working memory: Stance · Position · In progress · Next planned (above the fold, ≤ 5 KB)
curriculum.md      ← the concept layer (sections, milestones)
```

The pyramid is why per-session read cost stays bounded as the system ages. The mentor doesn't re-read three years of sessions to prepare; it reads the last two log entries, the curriculum section its focus sheet names, and everything above the fold — that's it.

**The fold.** Five files (`MEMORY.md`, `profile.md`, `season_current.md`, `coordinator_state.md`, each `current_focus.md`) carry the line `## ── HISTORY (on demand; agents do not read past this line) ──`. Current state lives above it; every story and superseded state lives below it, verbatim. Agents read to the fold; each file's header states its above-the-fold budget, and the weekly review measures it. Over budget means *move below the fold*, never delete. Three file kinds follow from this: ledgers (edit by ID, retire below the fold), working memory (replace a section in place), logs (append; readers take the tail) — see `core/PROTOCOLS.md → FILE KINDS`.

---

## Coordinator vs domain mentor

| | Coordinator | Domain Mentor |
|---|---|---|
| **Scope** | Across all active domains | One domain only |
| **Triggered by** | "weekly review", "season review" | "let's do a session on X" |
| **Reads** | Mentor reports, MEMORY.md, profile.md, coordinator_state.md (above the fold) | MEMORY.md + its own domain folder + profile.md (above the fold) |
| **Writes** | Synthesis across domains, next-week plan, coordinator_state.md | Its own domain's session page, log, catalog, focus |
| **Owns** | Evidence, cross-domain priority, capacity, sequencing, the checkpoints | Assessment, method, curriculum, research, calibration, the next-step recommendation |
| **Authority** | Whether a task belongs in the week | How the domain is practised |

The coordinator does **not** override a domain mentor's calibration — but it *can* tell a domain mentor "you're getting only one session this week, plan accordingly". The domain mentor does not override another domain mentor — it can only flag concerns to the coordinator.

**Challenge, don't replace.** A good coordinator argues: it asks a mentor to defend a task's relevance, timing, evidence and trade-off, and the mentor answers *keep / revise / withdraw* with evidence. What it may not do is author a replacement task, change a mentor's method, cut an exercise below the mentor's stated minimum, or quietly cover a domain whose mentor report failed. Unresolved disagreement goes to you with both positions shown — you decide.

That line matters more the longer the system runs. Both roles can run on the same strong model; capability is not authority. If the coordinator gradually absorbs each mentor's knowledge, in a year you have one tangled intelligence and no file with a single owner — which is exactly what the layer pyramid (P8) and `framework/PROTOCOLS.md → DOMAIN OWNERSHIP` exist to prevent. `coordinator_state.md` holds decisions and pointers; domain teaching material stays in the domain folder, and a weekly drift check moves it back if it strays.

---

## Critical thinking is built in

A naïve LLM agrees with whatever you said last. The protocols include explicit guards against this:

1. **Signal triage.** For each user comment in the signal brief, classify it: genuine insight / comfort-seeking / legitimate pivot / noise. Classifications use *reasoning + pattern history* as the heuristic, not vibes.
2. **Devil's advocate.** For each recommendation the mentor is about to make, state the strongest counter-argument. If the counter is stronger, change the recommendation.
3. **Historical pattern gate.** Before silently complying with a request that implies a plan change, check whether a similar request has appeared before, whether it fits an established avoidance pattern, and whether the timing coincides with a difficulty spike.

If 2+ of these flags fire, the mentor escalates the question to you at the next checkpoint rather than silently changing course. This is the system's main defense against "I just want to be told yes".

See `.claude/skills/weekly-review/mentor_prompt.md` → step 7 for the full spec.

---

## Memory: how the system learns

A naïve assistant forgets your corrections the moment the thread ends. Trellis puts them in a single always-read file, `mentors/MEMORY.md`, with four short sections above the fold (the full stories sit below it) — and every mentor reads it *before* it drafts:

- **RULES** — every correction you give becomes a 3–4-line pre-flight rule with a `✓` question and a violation count. Because mentors answer these rules (pass/fail) in a PREFLIGHT block before proposing anything, a correction you give in week N provably changes behaviour in week N+1. If a rule is violated twice, the fix must become structural, not another reminder.
- **FACTS** and **NEVER-REPEAT** — the load-bearing facts you've stated, and the things you've declined. A plan that contradicts a row is wrong by definition. FACTS is a *pointer* layer — each row names its home file — so it doesn't create drift; the weekly DRIFT_CHECK reconciles it.
- **ASKS** — a ledger of open requests with a mechanical, age-based escalation: an ask unmet for 2 reviews escalates to a named owner; unmet for 3, it becomes a challenge you *must* see. No urgent ask can quietly rot for weeks.

This is the difference between a system that keeps a diary of its mistakes and one that actually reads them back — and it's the minimum trust layer for a second user: when you correct it, it stays corrected.

Three supporting mechanisms in the weekly review reinforce it: a **THREE_MOVES** step forces each mentor to produce a non-obvious move (not a checklist); a **fresh-context verifier** — an agent that did not write the plan — checks it against FACTS / NEVER-REPEAT / locked slots / done work / progressive overload *before* you see it, so the system catches its own errors instead of you catching them after; and a **correction count** records, every week, how many mentor errors you still had to fix at plan approval and how many the verifier caught first.

---

## Seasons

A **season** is a fixed-duration arc (90 days by default) with explicit exit criteria per active domain. It bounds ambition, forces choices about what's Active vs Silent right now, and creates a natural archive boundary.

Without seasons, the system sprawls — every new interest accretes, nothing ever closes, the mentor's "current focus" sheet becomes a multi-page wishlist that no longer focuses anything.

At season end, the **SEASON_TRANSITION** protocol:

1. Per-domain: marks each exit criterion Met / Partially Met / Not Met with one-line reasoning.
2. Archives the season's work into `archive/season_<N>_<period>.md`, synthesized from the season's `log.md` entries.
3. Rotates `profile.md` and `MEMORY.md`: resolved patterns, absorbed rules and dead facts move below the fold (never deleted).
4. Designs the next season: which domains are Active / Seeding / Silent, what each one is for, what its exit criterion is.

---

## What this system is NOT

- **Not a wiki.** A mentor's notebook is about a relationship, not a knowledge base. (A separate optional wiki layer is sketched in `core/WIKI_BRIDGE.md`.)
- **Not an LMS.** No structured fields, no schemas, no validators in the user-facing loop. The mentor asks the human question, writes the answer in prose, moves on.
- **Not a productivity tracker.** It doesn't tell you what to do today; it tells you what the next *right* thing is given everything it knows.
- **Not vendor-locked.** Markdown in git. Take it anywhere.

---

## Where to go from here

- The constitution: [`core/FIRST_PRINCIPLES.md`](../core/FIRST_PRINCIPLES.md)
- The operating manual: [`core/PROTOCOLS.md`](../core/PROTOCOLS.md)
- A worked example: [`examples/example_domain/`](../examples/example_domain/)
- Customization: [`docs/customization.md`](customization.md)
- Connectors: [`docs/connectors.md`](connectors.md)
