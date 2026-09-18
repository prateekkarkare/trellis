---
name: weekly-review
description: Run the WEEKLY_REVIEW protocol for the mentor team. Use when {{USER_NAME}} says "weekly review", "review my week", or the scheduled review day fires. Loads the full 5-phase procedure (gather → checkpoint → parallel mentors → synthesis + fresh-context verifier → checkpoint → writes + budget check → present).
---

# WEEKLY_REVIEW (canonical procedure)

*This skill is the canonical text for WEEKLY_REVIEW. It is carved out of `framework/PROTOCOLS.md` so it loads verbatim on trigger instead of depending on the whole manual being read. If the skill mechanism is unavailable, read this file directly — it is plain, self-contained markdown. MONTHLY_REVIEW and SEASON_TRANSITION (in `framework/PROTOCOLS.md`) extend this procedure. The mentor agents' instructions live in `[ROOT]/.claude/skills/weekly-review/mentor_prompt.md`.*

**PATH & DATE DISCOVERY (run first):** Run `date` first and take "today" only from it — never from the conversation, file timestamps, or {{USER_NAME}}'s day references; compute every review-window date from the shell clock (miscounting the week has corrupted schedules before). Then find `[ROOT]`, the notebook root — the directory that contains `CLAUDE.md` and `mentors/`. If the working directory isn't it:
```bash
find ~ /sessions -maxdepth 6 -name MEMORY.md -path '*/mentors/*' -not -path '*/.git/*' 2>/dev/null | head -1
```
and strip `/mentors/MEMORY.md`. Use `[ROOT]` in all paths below. Fold files are read above the fold only: `sed -n '1,/^## ── HISTORY/p' <file>`.

**MEMORY (read before anything else):** above the fold only — `sed -n '1,/^## ── HISTORY/p' [ROOT]/mentors/MEMORY.md`, or (preferred once the top half is large — Bash output is capped at ~48 KB) `grep -n '^## ── HISTORY' [ROOT]/mentors/MEMORY.md` → fold line N → Read lines 1 to N−1: `## RULES` (each a 3–4-line pre-flight with a `✓` question and a `[v:N]` violation count), `## FACTS` + `## NEVER-REPEAT` (binding rows), `## ASKS — open`. **Increment every open ASKS row's Age in place now (edit by ID).** A story below the fold is read on demand: `grep -n '^\*\*L35 ' [ROOT]/mentors/MEMORY.md` → Read from that line.

## PROTOCOL: WEEKLY_REVIEW

**Trigger**: {{USER_NAME}} says "weekly review" or "review my week" in conversation, or the scheduled review-day task fires
**Frequency**: Every `WEEKLY_REVIEW_DAY` (from `CONFIG.md`; Sunday by default). A one-day slip is fine — the system adjusts forward, never backward.
**Total runtime**: ~5 min of model work per turn, ~15 min of {{USER_NAME}}'s reading

### HOW THIS PROTOCOL RUNS — READ THIS FIRST

**First, read `CONFIG.md` → `PROTOCOL_MODE`.** It has two valid values:

- **`checkpoints`** (default, safer) — pause at each ⏸ CHECKPOINT below, surface the brief/plan, and wait for {{USER_NAME}}'s reply before continuing. Nothing is written to disk until the checkpoint is cleared. Whether the run was a scheduled task ("Run Now") or a chat trigger, it behaves the same way: **two real pauses, {{USER_NAME}}'s input required at each, nothing written until approved.** At each ⏸, post the brief/plan as your response text, then call the **AskUserQuestion** tool (or the client's question/prompt tool) with the block given there; the tool holds the run until they answer and the same thread continues. If AskUserQuestion is unavailable in this run, post the checkpoint text and stop generating; {{USER_NAME}}'s reply in this thread continues the protocol.
- **`automated`** — do NOT pause. Make best-judgement decisions at every checkpoint, proceed straight through to PHASE 4, and deliver a single final report at the end that contains: (a) the Signal Brief you would have shown at Checkpoint 1, (b) the Plan you would have shown at Checkpoint 2 with its Self-check, (c) the diffs written in PHASE 4, and (d) an explicit "automated decisions log" listing every judgement call you made at a gate without input. The user can audit and roll back any write afterwards. The AskUserQuestion blocks below are skipped in this mode.

### PHASE 1 — COORDINATOR GATHERS
*Run yourself. No agents yet.*

> **First review after INTAKE (weeks 1–2): run the light version.** If the notebook was intaked fewer than ~2 weeks ago, or no connector is wired and `log.md` / `sessions/` are nearly empty, you have almost no behavioural signal yet — and that is *expected, not a failure*. Do not manufacture trends from two data points. Instead: (a) read what little exists (the intake profile, any session pages, files touched this week); (b) at Checkpoint 1, say plainly *"signals are thin this early — here's the little I have and what I'm watching for"*; and (c) build the plan primarily off the season exit criteria and the intake baseline rather than off completion patterns. Full pattern detection switches on naturally around week 3–4, once there's real history to read. Tell the user that — it keeps them from misreading an honest early week as the system underperforming.

**Step 1.1 — Discover path.** Run path discovery above. Store as `[ROOT]`.

**Step 1.2 — Read signal sources**

Your **task connector** (configured in `CONFIG.md`; see `connectors/`) is the **primary signal channel**. Read it thoroughly and in layers. If no connector is wired or it is unavailable, fall back to TRACKER.md and flag the gap at Checkpoint 1.

**TASK CONNECTOR — read in this exact sequence (adapt the verbs to your connector):**

**Call 1 — Past week tasks (due or completed in the past 7 days):** Fetch every task with a due date in the past 7 days, regardless of completion status, plus every task completed in that window. For each task record:
- Task name and content
- Due date as scheduled
- Completion status (done / not done / rescheduled)
- Time of completion if available — this is the energy-pattern signal
- Labels and project (used to infer domain)
- Whether the task was rescheduled from an earlier date (and how many times) — repeated reschedules on the same task = avoidance signal, not busyness

**Call 2 — Comments on every task retrieved above:** For each task from Call 1, fetch all comments. Comments are the most valuable signal in the system. They are {{USER_NAME}}'s voice. For each comment:
- Quote it verbatim — do not paraphrase
- Note which task it belongs to and the comment date
- Classify it: reason-for-skip / difficulty-note / external-context / insight / other
Silence (no comment on a skipped task) is also a signal — note it explicitly.

**Call 3 — Overdue and uncompleted tasks:** Any task that was due before today and is still open. Note: task name, original due date, how many days overdue. A task overdue by 1 day = likely friction. Overdue by 3+ days = avoidance pattern. Overdue by 7+ days = structural barrier worth surfacing to mentors.

**Synthesis — do this before building the WEEK_BRIEF:** After reading all three layers, synthesize per domain:
1. **Completion rate**: [X done] / [Y planned] — surface the number, not just the ratio
2. **Skip pattern**: which task types got skipped most? (e.g., runs vs yoga, evening vs morning)
3. **Comment signals**: list every comment verbatim, then draw the behavioural inference — e.g., comment "too tired after work" on 3 consecutive evening tasks → confirms low evening energy
4. **Avoidance vs. busyness**: was the skip random (different task types, different days) or clustered (same domain, same time slot) → clustered = pattern, not noise
5. **Reschedule chain**: tasks moved repeatedly forward are being avoided, not just deferred
6. **Positive signals**: tasks done early in the day, done consistently, done with a comment like "felt good" — these are anchors. Note them. Mentors should build around them.

**TRACKER.md — the current week's block only (do not read the whole file):** if you keep one, `grep -n '^## 📅' [ROOT]/TRACKER.md` → ranged Read of the block marked **THIS WEEK** (its header line to the next `## ` header). It holds the plan lines {{USER_NAME}} was working from and anything they noted there. If the connector and TRACKER.md conflict, the connector wins — {{USER_NAME}} acts there. If TRACKER.md has comments the connector doesn't, include them — they're still signal.

**OUTPUT SIGNAL — files touched in the past 7 days (one command):**
```bash
cd [ROOT] && find mentors knowledge-store -name '*.md' -mtime -7 -not -path '*/.git/*' 2>/dev/null | sort
```
List the files. Anything {{USER_NAME}} wrote (a note in a wired knowledge store, a session page, a plan they edited) is output — produced, not consumed (a video watched, a paper read). Together with their connector comments this fills the WEEK_BRIEF "OUTPUT CREATED THIS WEEK" section. No files for a domain = "no output" — signal, not shame.

2. `[ROOT]/mentors/profile.md` — above the fold: `sed -n '1,/^## ── HISTORY/p' [ROOT]/mentors/profile.md`. Note: energy patterns, behavioral patterns, calibration log summary, external teachers table. The dated weekly observations are below the fold — on demand only.
3. `[ROOT]/mentors/season_current.md` — above the fold (same command). Note: which domains are Active / Seeding / Silent. Locked external slots (External Schedule Anchors — verbatim; the verifier checks the plan against them). `## Upcoming dates & disruptions (next 6 weeks)`. Season start date, season end date. Exit criteria per domain.
4. `[ROOT]/mentors/cross_domain.md` — in full (small). Note: all scheduling constraints, time-stacking opportunities, synergy bridges.
5. `[ROOT]/mentors/coordinator_state.md` — above the fold (same command). Note: Risks, Trade-Offs, Capacity, High-Stakes, Calibration Drift, `## Active Watches — for the next review only` (last week's set — this is the review they were written for), `## Team board` (copied into the WEEK_BRIEF verbatim). Carry every open item forward to Phase 3 step 3.5 for an explicit add/edit/retire decision.
5a. MEMORY.md was read at the top and the ASKS ages are incremented. Any row at Age ≥ 2 is an ESCALATION for Checkpoint 1; any row at Age ≥ 3 is BLOCKING — a mandatory Mentor Challenge at Checkpoint 2 (Phase 3 step 3.4). This is mechanical — the coordinator does not get to decide an aged ask is fine.
6. **(Optional) the client's auto-memory index, if the client exposes one** (Cowork: `[ROOT]/../.auto-memory/MEMORY.md`; absent on a local checkout — skip silently). Auto-memory captures behavioral signals from ALL conversations, not just this notebook — a coding session, a writing session, anything. Read the index, then any `user` or `feedback` type entries updated since the last weekly review (check file modification timestamps if possible). Extract signals not yet present in profile.md: learning-style observations from non-mentor sessions, communication-preference updates, new feedback patterns (what the model got wrong, what worked well), contextual life signals (work stress, time constraints, energy shifts). These are upstream signals — wider net than profile.md, less structured. Note them separately; they feed Step 4f.

**Step 1.3 — Compute dates.** Run `date`, then compute: past week (the Mon–Sun that just ended) · next week (the Mon–Sun coming up) · season week number (count from season start date in season_current.md) · weeks remaining in season (count to season end date).

**Step 1.4 — Identify active domains.** From season_current.md, list all domains with state = Active or Seeding. These domains get a mentor agent in Phase 2. Silent domains are skipped.

**Step 1.5 — Build the WEEK_BRIEF.** This structured block is passed verbatim to every mentor agent. Fill it in precisely — it is the only signal mentors have about what actually happened.

```
WEEK_BRIEF
==========
Review date: [today's date]
Past week: [Mon date] – [Sun date] | Season [N] Week [W]
Next week: [Mon date] – [Sun date] | Season [N] Week [W+1]
Weeks remaining in season: [X]

COMPLETION DATA (source: task connector primary, TRACKER.md cross-reference)
----------------------------------------------------------------------
[For each active/seeding domain:]
[DOMAIN]:
  Planned: [list tasks as scheduled in the connector]
  Done ✅: [list with time-of-completion if available]
  Skipped ❌: [list — note if overdue and by how many days]
  Rescheduled ➡️: [list — note how many times each was moved]
  {{USER_NAME}}'s comments (verbatim): [quote every comment exactly; "none" if silent]
  Behavioural inference: [1 sentence — what do the above signals actually mean?]
[Omit domains with zero activity this week]

ENERGY SIGNAL THIS WEEK
-----------------------
Morning completions (tasks done before noon): [X/Y]
Evening completions (tasks done after 6pm): [X/Y]
Avoidance signals: [any tasks rescheduled 2+ times, or overdue 3+ days — name them]
Anchor habits (done consistently, done early): [name them — mentors should build around these]
Pattern vs prior weeks: [does this match established patterns in profile.md, or is something new?]

CONSTRAINTS FOR NEXT WEEK
--------------------------
Time budget: [TIME_FLOOR_PER_DOMAIN] min floor / [TIME_CEILING_PER_DAY] min ceiling on weekdays (from CONFIG.md). Weekends more flexible.
Locked slots (non-negotiable, from season_current.md):
  [list each: Day, time, domain, what it is]
Known disruptions next week: [from season_current.md → Upcoming dates & disruptions + anything mentioned; "none" if none]

OUTPUT CREATED THIS WEEK (source: files modified in the past 7 days + connector comments)
----------------------------------------------------------------------------------------
[For each active/seeding domain:]
[DOMAIN]:
  Created: [list anything produced — blog lines, composition notes, recipe experiments, code notebooks, sketches, recordings, forum posts, etc.]
  Accumulated total: [if trackable — e.g. "blog draft: ~45 lines across 3 weeks"]
  If nothing: "no output" — this is signal, not shame.
[Omit domains with no files and no output comments]

TEAM BOARD (copied verbatim from coordinator_state.md → ## Team board)
-----------------------------------------------------------------------
[one line per active domain, ≤ 40 words each — where each domain stood after last week and the one thing another mentor could use. This is how mentors see each other. "none yet" on the first review.]

SEASON POSITION
---------------
Week [W] of [total weeks]. [X] weeks until season end ([end date]).
[If X <= 3: add "*** APPROACHING SEASON EXIT — mentors must evaluate exit criteria ***"]
```

### ⏸ CHECKPOINT 1 — SIGNAL BRIEF

**In `checkpoints` mode: post the signal brief (format below) as your response text, then immediately call the AskUserQuestion tool with the question below. Do not proceed to Phase 2 until the tool returns {{USER_NAME}}'s answer. In `automated` mode: record this brief for the final report and proceed.**

Format:

---
**Week [W] signals — does this look right?**

*[Past Mon] – [Past Sun]*

**Completion:**
| Domain | Done | Skipped | Rescheduled | Your comments |
|--------|------|---------|-------------|---------------|
| [domain] | [X/Y] | [list] | [list] | [verbatim quotes] |
[one row per active domain]

**What the signals say:**
[3–5 bullet points — the actual behavioural inferences, not just raw data.
e.g. "Run has been skipped 4 consecutive weeks with no comment — this is avoidance, not busyness"
e.g. "Guitar done every day before noon — strongest anchor habit in the system"
e.g. "The evening course module moved forward 3 times — evening cognitive load is the barrier"]

**Escalations (from MEMORY.md → ASKS):** [any Age ≥ 2 ask — name it and its owner; "none"]

**Energy:** [1 sentence on morning vs evening execution split this week]

**Data quality:** [task connector ✓ / connector unavailable — signals from TRACKER.md only ⚠️]

**AskUserQuestion call at Checkpoint 1:**
```
question: "Anything to add before I consult the mentors? (Say 'looks good' or describe what I missed)"
header: "Signal check"
options:
  - label: "Looks good — consult mentors"
    description: "Signal brief is accurate. Proceed with mentor consultation."
  - label: "I have context to add"
    description: "Select this and use the Other field to describe what I missed."
```
If AskUserQuestion is unavailable in this run, post the checkpoint text and stop; {{USER_NAME}}'s reply in this thread continues the protocol.

**When {{USER_NAME}} replies:** "looks good" → proceed to Phase 2 with no changes. Adds context → update WEEK_BRIEF with it, then proceed to Phase 2.

### PHASE 2 — PARALLEL MENTOR CONSULTATION
*Spawn all mentor agents in a SINGLE message (one Agent tool call per domain, all in parallel).*

The mentor instructions (read path, critical-thinking pass, report format) live in `[ROOT]/.claude/skills/weekly-review/mentor_prompt.md`; each agent reads that file itself. For each active/seeding domain from Step 1.4, the Agent prompt is exactly:

```
You are {{USER_NAME}}'s [DOMAIN] mentor for the S[N] W[W] weekly review. [ROOT] = <absolute path>.
FIRST read `[ROOT]/.claude/skills/weekly-review/mentor_prompt.md` in full and follow it exactly.
WEEK_BRIEF:
<paste the full WEEK_BRIEF, including TEAM BOARD>
```

Each report returns the fields defined there — PREFLIGHT, THREE_MOVES, …, VALUE_CHECK, TEAM_LINE, FOCUS_UPDATE, NEW_LESSON/NEW_FACT, LOG_ENTRY. Mentors never write files; you do, in Phase 4.

### PHASE 3 — SYNTHESIS AND CONFLICT RESOLUTION
*After all mentor agents return.*

**Step 3.1 — Time budget check.** Sum total time requested by all mentors for each weekday.
- If total ≤ `TIME_CEILING_PER_DAY` (CONFIG.md) on a given weekday: proceed.
- If over budget: identify the lowest-intensity domain for that day (use season_current.md domain intensities: High > Medium > Low). Send that mentor one targeted follow-up agent: "On [day] you requested [X] min. Total across all domains is [Y] min, ceiling is [ceiling] min. You have [Z] min. Keep your single highest-priority goal for that day. Drop the rest."
- Maximum one additional round per domain.

**Step 3.2 — Slot conflict check.** Check if two domains claim the same locked time slot (e.g., both want Monday 7:30am). If conflict: send back to the lower-priority domain with: "The [slot] on [day] is taken by [domain]. Revise your plan — that slot is unavailable."

**Step 3.3 — Cross-domain integration.** Review all CONCERNS_FOR_COORDINATOR fields from mentor reports.
- Apply time-stacking where possible (e.g., walk + audiobook = Fitness + Reading in one slot)
- Resolve dependencies (e.g., a teacher confirmed → update that domain's plan accordingly)
- Flag any behavioral concerns worth surfacing to {{USER_NAME}} in Phase 5

**Step 3.4 — Collect critical signals.** Review all CRITICAL_SIGNALS sections from mentor reports.
- Collect every flag marked "needs_discussion" — these become Mentor Challenges at Checkpoint 2.
- **ASKS escalation (mechanical):** any MEMORY.md → ASKS row at Age ≥ 3 is a MANDATORY Mentor Challenge this week — present why it keeps failing and propose a structural change (drop / change owner / change approach). It may not be silently carried. A row at Age 2 gets a named existing-mentor owner and a specific weekly deliverable (Upgrade 2).
- **PREFLIGHT audit:** scan every report's PREFLIGHT. Any `fail` without a fix, or any report missing the section, is sent back for one regeneration round. Stage every NEW_LESSON / NEW_FACT / `L## violated` for the Phase 4 MEMORY write.
- If multiple mentors flag the same behavioral pattern (e.g., two domains see avoidance of difficulty increase), consolidate into a single cross-domain challenge.
- Also apply the coordinator's own critical eye: if a mentor's signal triage seems wrong (e.g., mentor classified a comment as GENUINE INSIGHT but profile.md shows this is a recurring avoidance pattern), override and flag it.
- The coordinator is the final filter. Mentor flags that are trivial or clearly resolved by context can be dropped. Only surface challenges that genuinely need {{USER_NAME}}'s input.

**Step 3.5 — Update `coordinator_state.md` (above the fold, ≤ 14 KB).** The coordinator's own working memory — between-domain attention that no single mentor owns. Re-read the version loaded in Phase 1.
- Risks · Trade-Offs · Capacity · High-Stakes · Calibration Drift: edit items in place — add, change state, or retire by moving the line below the fold. No dated sections above the fold; the `*Last updated:*` header line carries the one-sentence summary of what changed this review.
- `## Active Watches — for the next review only`: move last week's set below the fold verbatim (under a dated sub-header there), then rewrite the section with this week's watches. A watch that still matters is re-written, not carried by inertia.
- `## Team board`: one line per active domain, ≤ 40 words, from each mentor's `TEAM_LINE`. Next week's WEEK_BRIEF copies it verbatim — this is how mentors see each other.
- This update happens BEFORE Checkpoint 2 — so the proposed plan reflects the freshly-updated coordinator state.

**Step 3.6 — VERIFIER (fresh context).** One Agent call. The coordinator wrote the plan and cannot see its own blind spots; a fresh context can. The Agent tool's per-call `model` parameter may be used for this call (optional). Its prompt is:

> You did not write this plan and you are not here to like it. Read: (1) the proposed Mon–Sun plan and mentor challenges pasted below; (2) `[ROOT]/mentors/MEMORY.md` above the fold (`sed -n '1,/^## ── HISTORY/p'`); (3) `[ROOT]/mentors/season_current.md` → External Schedule Anchors table; (4) for each active domain, `[ROOT]/mentors/<d>/done_topics.md` and the `## Binding F-ids` + `## Calibration flags` sections of `<d>/current_focus.md`. Return ONLY this block, each line either `none` or a concrete defect quoting the plan line and the conflicting file line:
> ```
> SELF-CHECK (W[N])
> - FACTS conflict: [none / lists any task contradicting a MEMORY.md → FACTS line]
> - Never-Repeat: [none / names any declined item that slipped in]
> - Locked slots: [every locked slot present on the board, no inversions / lists any missing slot, conflict or inversion]
> - done_topics overlap: [none / names any already-done work re-proposed]
> - Progressive overload: [each domain harder-or-equal vs last week? / names any step-down]
> - PREFLIGHT: [complete in every report / lists any missing section or unresolved fail]
> - ASKS ages: [no aged ask ignored / lists any Age≥3 not surfaced]
> - Verified entities: [every company/paper/venue/route named in the plan carries a verified-on date / list those that don't]
> - Task shape: [every task ≤ 150 words, defines its terms, has DONE-WHEN / list failures]
> ```
> [paste: proposed plan, mentor challenges, [ROOT] path, active domain list]

The coordinator fixes every non-`none` line before Checkpoint 2 (re-running the verifier if the fix was more than a line edit) and pastes the final block into the Checkpoint-2 message under **Self-check**. Count the defects it caught — Step 4h records the number. This pass is the difference between the system catching its own errors and {{USER_NAME}} catching them after the fact.

### ⏸ CHECKPOINT 2 — PLAN APPROVAL

**In `checkpoints` mode: post the proposed plan (format below) as your response text, then immediately call the AskUserQuestion tool with the question below. Do not proceed to Phase 4 until the tool returns {{USER_NAME}}'s answer. No files are written and no connector tasks are touched until cleared. In `automated` mode: record the plan for the final report and proceed to Phase 4.**

Format:

---
**Proposed plan for Week [W+1] — [Next Mon] – [Next Sun]**
*[Any mentor concerns or flags worth knowing before you decide]*

[ONLY if Step 3.4 produced any needs_discussion flags:]
**Mentor Challenges — your input needed before finalizing:**

[Number each challenge. Present as a direct question from the mentor to {{USER_NAME}}. Include: which domain, what the mentor observed, what they recommend, and what they need {{USER_NAME}} to weigh in on. Keep each challenge to 3–4 sentences max.]

1. **[Domain]**: [The challenge question, written in plain language. e.g. "You commented that the capstone exercise is 'too overview-level', but this is the 2nd consecutive week you've requested difficulty reduction after a skip. Log shows the prior reduction led to 3 weeks of stagnation. I recommend holding at current level for 1 more week. Should I hold, or do you have context I'm missing?"]

2. ...

[Max 3 challenges per week. Any Age ≥ 3 ask from Step 3.4 is one of them. If more exist, the coordinator picks the 3 most consequential. Trivial flags get resolved by the coordinator silently. If no flags: omit this section entirely — don't add "no challenges" noise.]

---

**Monday [date]**
- [domain]: [task] ([duration])
- [domain]: [task] ([duration])

**Tuesday [date]**
...
[continue Mon–Sun. Max 3 tasks per day. Written as {{USER_NAME}} will see them in the connector.]

**Micro-output targets this week:**
| Domain | Target | Accumulates toward |
|--------|--------|--------------------|
| [domain] | [2-5 min daily micro-output, its own named task on an anchor] | [eventual artifact: blog, composition, notebook, etc.] |

**One thing to protect:** [single most important commitment]
**One thing to watch:** [single behavioral signal to monitor]

**Self-check:** [the verifier's final SELF-CHECK block from Step 3.6, every line `none` or fixed]

---

**AskUserQuestion call at Checkpoint 2:**

[If NO mentor challenges were surfaced:]
```
question: "Approve this plan for next week?"
header: "Plan approval"
options:
  - label: "Looks good — write it"
    description: "Approve plan as-is. Phase 4 writes begin."
  - label: "I want to change something"
    description: "Select this and describe the change in the Other field."
```

[If mentor challenges WERE surfaced:]
```
question: "Review the mentor challenges above and approve or adjust the plan."
header: "Plan approval + mentor challenges"
options:
  - label: "Mentors are right — keep the plan as-is"
    description: "Accept all mentor recommendations including their challenge positions."
  - label: "I have responses to the challenges"
    description: "Use the Other field to respond to specific challenges by number."
  - label: "Override — I want to change the plan"
    description: "Use the Other field to describe changes. Mentors' concerns noted but overridden."
```
If AskUserQuestion is unavailable in this run, post the checkpoint text and stop; {{USER_NAME}}'s reply in this thread continues the protocol.

**When {{USER_NAME}} replies:**
- "looks good" / "mentors are right" → proceed to Phase 4 with no changes.
- responds to challenges → apply their responses to the plan. If a response provides genuine reasoning that the mentor didn't have, accept it and adjust. If the response is itself comfort-seeking (no new reasoning, just restating preference), the coordinator notes this in profile.md behavioral patterns but still respects the decision — they are the principal, not the mentors. One round only — do not ask again.
- requests changes → apply them, proceed to Phase 4. One round only — do not ask again.
- **Count every distinct mentor error they corrected here** (a wrong fact, a slot missed, a done topic re-proposed, a bogus task) — Step 4h writes the number.

### PHASE 4 — WRITE OUTPUTS
*Run the writes sequentially. Only execute after Checkpoint 2 is cleared (checkpoints mode) or straight through (automated mode). Three file kinds, three write rules (PROTOCOLS.md → FILE KINDS): **ledgers** (MEMORY, done_topics) edit by ID or append; **working memory** (current_focus, coordinator_state, season_current) replaces sections in place; **logs** (log.md, TRACKER) append. Nothing above a fold gets a dated section.*

**Step 4a — Task connector: wipe and rewrite (if connected)**

All connector signals were already captured in Phase 1 — including unfinished and overdue tasks. By the time this step runs, every signal has been read, synthesised into WEEK_BRIEF, seen by mentor agents, and incorporated into the approved plan. Only now is it safe to wipe.

1. **Delete all existing tasks**: fetch all open tasks, delete them entirely. The connector is not the long-term record — TRACKER.md / the notebook is. Deleted tasks are not lost; their signals are already in WEEK_BRIEF and will be written to log.md and TRACKER.md. Do not skip this step or leave stale tasks behind — a cluttered connector creates friction.

2. **Write next week clean**: create one task per planned session (Mon–Sun).
   - **Task title**: "[Domain]: [specific what to do]" · due date = correct date · duration if supported. Use domain labels/projects if established. Max 3 tasks per day.
   - **Task description is MANDATORY and must be self-contained.** A title is a label, not an instruction. Each description carries, sourced from the domain's `curriculum.md` / `current_focus.md` / mentor report (NOT invented, NOT compressed to a slogan):
     - **WHAT** — the concrete action, with the specific lesson/chapter/dataset/number named.
     - **WHY** — one line on what this builds toward (the curriculum/season link).
     - **HOW** — the actual steps, including any primer needed to understand a term used (define acronyms; a task may not reference a concept the description doesn't explain).
     - **DONE WHEN** — explicit completion criteria.
   - End each description with: "Full primer in WEEK_BRIEFING.md."
   - **Domain rules are binding here.** Honour each domain's calibration rules from `current_focus.md` (e.g. a music domain: source-material only, no invented phrases; a technical domain: every task needs synthesis/judgment/production).

3. **VALIDATION GATE (reject before writing).** For every task, check: (a) Could it be completed by a single AI query in <10 min as a standalone? → it's a retrieval task; fold it into a harder exercise as context or cut it. (b) Does the description define every term it uses? → if not, add the primer. (c) Does it state DONE-WHEN? → if not, add it. (d) Does it contradict a MEMORY.md → FACTS line or a NEVER-REPEAT row, or re-propose done work? → cut it. (e) Does it violate a domain rule? → fix or cut. A task that fails the gate does not get written.

Result: the connector contains exactly next week's plan, every task self-contained and gate-passed. Nothing else. If no connector is wired: skip this step, note it in Phase 5.

**Step 4a.1 — Write WEEK_BRIEFING.md (the primary read surface).** Write `[ROOT]/WEEK_BRIEFING.md`: the full expert briefing {{USER_NAME}} reads on their phone alongside the checklist. One section per task, grouped by day, each with WHAT / WHY / HOW (step-by-step, with primers) / DONE WHEN / TIME. This is where mentor expertise lives at full fidelity — the connector description is the compressed carry, this is the source. Lead with the week theme + locked slots; include the "Answers you asked for" section (written mentor answers to their open comments — Upgrade 4). This file is overwritten each week (it is this-week-only; TRACKER.md holds history).

**Step 4b — Update each domain's log.md.** For each mentor report: append the LOG_ENTRY field verbatim to `[ROOT]/mentors/[domain]/log.md`. Do not edit or reformat the entry. Append only — never overwrite existing entries.

**Step 4b.1 — Update each domain's done_topics.md and current_focus.md (the P1 fix in action).** For each mentor report:
1. For every session listed in the LOG_ENTRY for this past week, append a row to `[ROOT]/mentors/[domain]/done_topics.md` if not already present (LINT-style reconciliation). Update *Last updated* and refresh *Next uncovered topics* from curriculum position.
2. **Apply the mentor's `FOCUS_UPDATE`**: replace exactly the named `## …` sections of `[ROOT]/mentors/[domain]/current_focus.md` above the fold with the mentor's replacement text. Never append a dated block — the reason for the change is in this week's LOG_ENTRY. The file stays ≤ 5 KB above the fold (Step 4i checks).

**Step 4b.2 — Run DRIFT_CHECK per active domain.** Run the DRIFT_CHECK protocol (`framework/PROTOCOLS.md`) for each active or seeding domain. Surface findings in the Phase 5 presentation.

**Step 4b.3 — Update MEMORY.md (the loop that makes the system learn — every review, per the write rule in its header)**
1. **New lesson** — from any NEW correction {{USER_NAME}} gave this week (a "bogus"/"mundane"/"weakly planned" rebuke, a factual error they caught, a declined item) or a mentor's NEW_LESSON: one 3–4-line entry in `## RULES` (`**L## · name** [v:0]` / `RULE: …` / `✓ <pre-flight question>` / `Why: "<their quote>" (adopted <date>) → story`) + the full story appended at the very end of the file under `## Stories added`. At the cap: retire or merge before adding.
2. **Violation** of an existing rule — edit its `[v:N]` in place. **At 2 the prose fix has failed → STRUCTURAL**: state the structural change (protocol / curriculum / format edit) in the story and tag the entry `[v:2 → STRUCTURAL <date>]`.
3. **New fact** — one row in `## FACTS` (`| F## | short fact | home | origin |`) + story at the end. A superseded fact is edited in place — never two versions. **NEVER-REPEAT** — one row.
4. **ASKS** — edit the row in place (Age, Status; owner + named deliverable when escalated). New asks → a new row at Age 0. Closed asks → move the row below the fold with the closing artifact named **and {{USER_NAME}}-confirmed** (only the principal closes an ask — self-declared resolution is prohibited).
No correction leaves the review unrecorded.

**Step 4c — Update TRACKER.md (if you keep one).** In `[ROOT]/TRACKER.md` (one `## 📅 SEASON [N] — Week [W] …` block per week): (1) mark the past week's block COMPLETED and add its 3-line completion summary (ticked/planned, the value verdict, the headline signal); (2) write the next week's block marked **THIS WEEK** in the same daily format as existing blocks — plan lines only, cross-domain time-stacking already applied (full detail lives in WEEK_BRIEFING.md). Skip if you don't keep a TRACKER.md — WEEK_BRIEFING.md + the connector + logs already hold the plan; Step 4h then writes its line to coordinator_state.md's header instead.

**Step 4d — Update season_current.md (above the fold, ≤ 10 KB).** (1) `## Upcoming dates & disruptions (next 6 weeks)`: edit the table in place — add anything new mentioned this week, drop rows whose date has passed (they already live in TRACKER.md and log.md). (2) Domain States: edit a domain's track note in place if it is significantly off-track. (3) External Schedule Anchors: add any new locked slot confirmed this week, verbatim.

**Step 4e — Apply curriculum adaptations.** For each mentor report with CURRICULUM_ADAPTATION ≠ "no change": read the affected section of `[ROOT]/mentors/[domain]/curriculum.md`; apply the specific change proposed by the mentor (resource swap, pacing change, new milestone, etc.); add a dated comment at the change site: `<!-- Adapted [date]: [reason] -->`. This is how curriculum stays alive. Small changes compound — a curriculum that adapts weekly is fundamentally different from one written once.

**Step 4f — Update profile.md (synthesis from all signal sources).** Sources: auto-memory (wide net, cross-session — if read in 1.2 step 6) + connector/TRACKER (this week's execution) + mentor reports (domain observations).
1. **This week's observation paragraph** (dated `S[N] W[W]`) is appended BELOW the fold — never above.
2. **Promotion**: a pattern that has now held ≥ 2 weeks (this week's observation + an earlier one) goes into the relevant section above the fold as ONE line with a first-observed tag (e.g. `(first seen S1 W3)`), or an existing line is edited in place. Translate auto-memory language into mentor-usable language — synthesise, never copy entries verbatim.
3. **Calibration Log summary**: edit in place from the mentors' DIFFICULTY_SIGNALs. **External Teachers** table: edit in place when a teacher/course is confirmed.
Direction is always auto-memory → profile.md. Never write back to auto-memory from here — auto-memory updates happen organically through conversations.

**Step 4g — Year archive (only if this is the first WEEKLY_REVIEW of a new calendar year).** For each domain that had any session activity in the year that just ended, write `[ROOT]/mentors/<domain>/archive/year_<YYYY>.md` using the year-archive template in `templates/domain/README.md`. Source material: every `archive/season_*.md` written within that calendar year. Required sections: year-in-review (3–5 paragraphs covering arc, what stuck, what was dropped, calibration drift across the year, biggest pattern shifts in {{USER_NAME}}'s behaviour in this domain, biggest artifacts produced), season index (one paragraph per season + archive pointer), patterns that crossed seasons. Immutable once written. Skip the step entirely on any other week.

**Step 4h — CORRECTION COUNT.** Append to the TRACKER block of the week just reviewed one line: `CP2 corrections: N · verifier caught: M` — N = the number of distinct mentor errors {{USER_NAME}} corrected at Checkpoint 2 this review; M = defects the Step 3.6 verifier caught before CP2. These two numbers are the system's error series; Phase 5 reports last week's N. (In `automated` mode N is 0 by construction — say so, and report M.)

**Step 4i — BUDGET CHECK (last, before commit)**
```bash
cd [ROOT] && for f in mentors/MEMORY.md mentors/profile.md mentors/coordinator_state.md mentors/season_current.md mentors/*/current_focus.md; do printf '%7d  %s\n' "$(sed -n '1,/^## ── HISTORY/p' "$f" | wc -c)" "$f"; done
grep -n '^##.*20[0-9][0-9]-[0-9][0-9]' mentors/MEMORY.md mentors/profile.md mentors/coordinator_state.md mentors/season_current.md mentors/*/current_focus.md | grep -v 'HISTORY'
```
Each file's header states its budget (defaults: MEMORY ≤ 25 KB, profile ≤ 30 KB, coordinator_state ≤ 14 KB, season_current ≤ 10 KB, current_focus ≤ 5 KB each; if a header and this list differ, the header wins). Any top half over budget, or any dated `##` header above a fold (the grep must print nothing, apart from lines below the fold — check each printed line number against that file's fold line number from `grep -n '^## ── HISTORY'`), is fixed NOW by moving content below the fold — never by deleting. This is P6: it measures the derived layer; it never gates {{USER_NAME}}. Paste the size table into the commit message if you commit.

**Step 4j — (Optional) Commit the notebook.** Sync is optional and never blocks the review. If you keep the notebook in git, run `scripts/sync.sh "review: S[N] W[W] weekly review (approved)"` or `git add -A && git commit`. See `framework/PROTOCOLS.md` → "Keeping your notebook in git (optional)".

### PHASE 5 — PRESENT TO {{USER_NAME}}
*Clean, phone-readable. No file paths. No implementation details.*

Present this structure:

---
**WEEKLY REVIEW — Season [N], Week [W]**
*[Past Mon]–[Past Sun] → [Next Mon]–[Next Sun]*

**How the week went:**
[2–3 honest sentences. Surface the real pattern — what was consistent, what was dropped, what the trend means. Not cheerleading.]
Corrections at Checkpoint 2 last week: N

**Domain snapshot:** *(value, not completion, is the headline — a domain at 100% completion with a bogus flag is not "on track")*
| Domain | Status | Key signal | Value | Output this week |
|--------|--------|------------|-------|-----------------|
| [domain] | [On track / Slightly behind / Behind / Concern] | [1 specific line] | [landed / low / bogus — from VALUE_CHECK] | [what was created, or "—"] |
[one row per active/seeding domain]

**Micro-output targets (2-5 min/day):**
| Domain | This week's target | Building toward |
|--------|-------------------|-----------------|
| [domain] | [specific tiny daily action] | [eventual artifact] |

**Next week:**
[Mon–Sun plan. Each day: list domains + tasks + duration, max 3 tasks/day. Short enough to read on a phone in 2 minutes.]

**One thing to protect:** [The single most important commitment that cannot slip. One sentence.]

**One thing to watch:** [The single behavioral signal or risk worth monitoring this week. One sentence.]

[If DRIFT_CHECK proposed actions, no connector was wired, or the run was `automated`: one line each, at the end.]

---
