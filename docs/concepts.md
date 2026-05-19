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
| **PREPARE** | Before a session | Read done_topics, current_focus, curriculum, log. Most importantly: don't propose work that's already done. |
| **COACH** | During | Have the conversation. Push back when warranted. Calibrate difficulty. |
| **JOURNAL** | After | Write the session page. Update the catalog. Update the focus sheet. Edit the curriculum if it shifted. |
| **AUDIT** | Periodically | Re-read the folder for drift, contradictions, stale claims. Happens inside the weekly review. |

Named protocols in `core/PROTOCOLS.md` (DOMAIN_SESSION, WEEKLY_REVIEW, MENTOR_REFRESH, SEASON_TRANSITION, DRIFT_CHECK) are these four operations specialized to different cadences and scopes.

---

## The layer pyramid (P8)

One canonical layer per granularity. Higher layers are mentor-compressed from lower; never written in parallel.

```
sessions/<date>.md        ← session granularity     (full prose)
        ↓ mentor compresses at session end
log.md                    ← chronological index     (one line per session)
        ↓ mentor summarizes at phase boundary
archive/phase_<N>.md      ← phase synthesis
        ↓ mentor summarizes at season boundary
archive/season_<N>.md     ← season synthesis
        ↓ mentor summarizes at year boundary
archive/year_<YYYY>.md    ← year-in-review
```

Aside (state, not history — bounded by construction):

```
done_topics.md     ← topic-granularity catalog (the "don't repeat work" rule)
current_focus.md   ← week/phase working memory
curriculum.md      ← the concept layer (phases, milestones)
```

The pyramid is why per-session read cost stays bounded as the system ages. The mentor doesn't re-read three years of sessions to prepare; it reads the current phase + the previous phase archive, that's it.

---

## Coordinator vs domain mentor

| | Coordinator | Domain Mentor |
|---|---|---|
| **Scope** | Across all active domains | One domain only |
| **Triggered by** | "weekly review", "season review" | "let's do a session on X" |
| **Reads** | All domain summaries, profile.md, coordinator_state.md | Just its own domain folder + profile.md |
| **Writes** | Synthesis across domains, next-week plan, coordinator_state.md | Its own domain's session page, log, catalog, focus |
| **Authority** | Trade-offs *between* domains | Calibration *within* its domain |

The coordinator does **not** override a domain mentor's calibration — but it *can* tell a domain mentor "you're getting only one session this week, plan accordingly". The domain mentor does not override another domain mentor — it can only flag concerns to the coordinator.

---

## Critical thinking is built in

A naïve LLM agrees with whatever you said last. The protocols include explicit guards against this:

1. **Signal triage.** For each user comment in the signal brief, classify it: genuine insight / comfort-seeking / legitimate pivot / noise. Classifications use *reasoning + pattern history* as the heuristic, not vibes.
2. **Devil's advocate.** For each recommendation the mentor is about to make, state the strongest counter-argument. If the counter is stronger, change the recommendation.
3. **Historical pattern gate.** Before silently complying with a request that implies a plan change, check whether a similar request has appeared before, whether it fits an established avoidance pattern, and whether the timing coincides with a difficulty spike.

If 2+ of these flags fire, the mentor escalates the question to you at the next checkpoint rather than silently changing course. This is the system's main defense against "I just want to be told yes".

See `core/PROTOCOLS.md` → `WEEKLY_REVIEW` Phase 2 step 7 for the full spec.

---

## Seasons

A **season** is a fixed-duration arc (90 days by default) with explicit exit criteria per active domain. It bounds ambition, forces choices about what's Active vs Silent right now, and creates a natural archive boundary.

Without seasons, the system sprawls — every new interest accretes, nothing ever closes, the mentor's "current focus" sheet becomes a multi-page wishlist that no longer focuses anything.

At season end, the **SEASON_TRANSITION** protocol:

1. Per-domain: marks each exit criterion Met / Partially Met / Not Met with one-line reasoning.
2. Archives the season's work into `archive/season_<N>_<period>.md`.
3. Optionally rotates state in `profile.md` if persistent patterns shifted.
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
