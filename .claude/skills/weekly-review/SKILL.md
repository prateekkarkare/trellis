---
name: weekly-review
description: Run the WEEKLY_REVIEW protocol for the mentor team. Use when {{USER_NAME}} says "weekly review", "review my week", or the scheduled review day fires. Loads the full 5-phase procedure (gather → checkpoint → parallel mentors → synthesis+verification → checkpoint → writes → present).
---

# WEEKLY_REVIEW (canonical procedure)

*This skill is the canonical text for WEEKLY_REVIEW. It is carved out of `framework/PROTOCOLS.md` so it loads verbatim on trigger instead of depending on the whole manual being read. If the skill mechanism is unavailable, read this file directly — it is plain, self-contained markdown. MONTHLY_REVIEW and SEASON_TRANSITION (in `framework/PROTOCOLS.md`) extend this procedure.*

**PATH DISCOVERY (run first):**
```bash
find /sessions -name "profile.md" -path "*/mentors/*" -not -path "*/.git/*" 2>/dev/null | head -1
```
Strip `/mentors/profile.md` to get `[ROOT]`, the notebook root. If your client mounts the notebook at a stable path, `[ROOT]` is simply the notebook folder. Use `[ROOT]` in all paths below.

**MEMORY (read before anything else):** `[ROOT]/mentors/MEMORY.md` — LESSONS (pre-flight rules), FACTS (binding facts + Never-Repeat), ASKS (open-ask ledger with mechanical age escalation). Small file, read in full.

## PROTOCOL: WEEKLY_REVIEW

**Trigger**: {{USER_NAME}} says "weekly review" or "review my week" in conversation
**Frequency**: Every `WEEKLY_REVIEW_DAY` (from `CONFIG.md`; Sunday by default). A one-day slip is fine — the system adjusts forward, never backward.
**Total runtime**: ~5 min of model work per turn, ~15 min of {{USER_NAME}}'s reading

### HOW THIS PROTOCOL RUNS — READ THIS FIRST

**First, read `CONFIG.md` → `PROTOCOL_MODE`.** It has two valid values:

- **`checkpoints`** (default, safer) — pause at each ⏸ CHECKPOINT below, surface the brief/plan, and wait for {{USER_NAME}}'s reply before continuing. Nothing is written to disk until the checkpoint is cleared.
- **`automated`** — do NOT pause. Make best-judgement decisions at every checkpoint, proceed straight through to PHASE 4, and deliver a single final report at the end that contains: (a) the Signal Brief you would have shown at Checkpoint 1, (b) the Plan you would have shown at Checkpoint 2, (c) the diffs written in PHASE 4, and (d) an explicit "automated decisions log" listing every judgement call you made at a gate without input. The user can audit and roll back any write afterwards.

For `checkpoints` mode, the protocol runs in two contexts and behaves the same way in both:

**Context A — Scheduled task (Run Now):**
{{USER_NAME}} triggers the task manually from the client interface.
The task runs in its own isolated thread with full history.
At each checkpoint, use the client's question/prompt tool (e.g. **AskUserQuestion**) to pause execution and collect input.
The tool holds the run until {{USER_NAME}} responds, then execution continues in the same thread.

**Context B — Conversation trigger:**
{{USER_NAME}} says "weekly review" in a chat session.
At each checkpoint, post the brief/plan and stop generating. Wait for {{USER_NAME}}'s reply.
Their reply in the same conversation thread continues the protocol.

In `checkpoints` mode (both contexts): **two real pauses, {{USER_NAME}}'s input required at each, nothing written until approved.**
In `automated` mode: **zero pauses, single final report, full write-audit trail at the end.**

---

### PHASE 1 — COORDINATOR GATHERS
*Run yourself. No agents yet.*

> **First review after INTAKE (weeks 1–2): run the light version.** If the notebook was intaked fewer than ~2 weeks ago, or no connector is wired and `log.md` / `sessions/` are nearly empty, you have almost no behavioural signal yet — and that is *expected, not a failure*. Do not manufacture trends from two data points. Instead: (a) read what little exists (the intake profile, any session pages, the daily log); (b) at Checkpoint 1, say plainly *"signals are thin this early — here's the little I have and what I'm watching for"*; and (c) build the plan primarily off the season exit criteria and the intake baseline rather than off completion patterns. Full pattern detection switches on naturally around week 3–4, once there's real history to read. Tell the user that — it keeps them from misreading an honest early week as the system underperforming.

**Step 1.1 — Discover path**
Run path discovery above. Store as `[ROOT]`.

**Step 1.2 — Read signal sources**

Your **task connector** (Todoist by default — see `connectors/`) is the primary signal channel. Read it thoroughly and in layers.
If no task connector is wired, fall back to `TRACKER.md` / the daily log and flag the gap at Checkpoint 1.

---

**TASK CONNECTOR — read in this exact sequence (examples use Todoist verbs; adapt to your connector):**

**Call 1 — Past week tasks (due or completed in the past 7 days):**
Fetch every task with a due date in the past 7 days, regardless of completion status.
For each task record:
- Task name and content
- Due date as scheduled
- Completion status (done / not done / rescheduled)
- Time of completion if available — this is the energy-pattern signal
- Labels and project (used to infer domain)
- Whether the task was rescheduled from an earlier date (and how many times)
  — repeated reschedules on the same task = avoidance signal, not busyness

**Call 2 — Comments on every task retrieved above:**
For each task from Call 1, fetch all comments.
Comments are the most valuable signal in the system. They are {{USER_NAME}}'s voice.
For each comment:
- Quote it verbatim — do not paraphrase
- Note which task it belongs to and the comment date
- Classify it: reason-for-skip / difficulty-note / external-context / insight / other
Silence (no comment on a skipped task) is also a signal — note it explicitly.

**Call 3 — Overdue and uncompleted tasks:**
Any task that was due before today and is still open.
Note: task name, original due date, how many days overdue.
A task overdue by 1 day = likely friction. Overdue by 3+ days = avoidance pattern.
Overdue by 7+ days = structural barrier worth surfacing to mentors.

**Synthesis — do this before building the WEEK_BRIEF:**
After reading all three layers, synthesize per domain:

1. **Completion rate**: [X done] / [Y planned] — surface the number, not just the ratio
2. **Skip pattern**: which task types got skipped most? (e.g., runs vs yoga, evening vs morning)
3. **Comment signals**: list every comment verbatim, then draw the behavioural inference
   e.g., comment "too tired after work" on 3 consecutive evening tasks → confirms low evening energy
4. **Avoidance vs. busyness**: was the skip random (different task types, different days)
   or clustered (same domain, same time slot) → clustered = pattern, not noise
5. **Reschedule chain**: tasks moved repeatedly forward are being avoided, not just deferred
6. **Positive signals**: tasks done early in the day, done consistently, done with a comment
   like "felt good" — these are anchors. Note them. Mentors should build around them.

---

**TRACKER.md — if present, always read, cross-reference:**
Read `[ROOT]/TRACKER.md` if it exists — extract the "Daily Activity Log" for the past 7 days.
Use this to catch anything the connector missed (e.g., tasks {{USER_NAME}} did that weren't tracked).
If the connector and TRACKER.md conflict, the connector wins — {{USER_NAME}} acts there.
If TRACKER.md has comments the connector doesn't, include them — they're still signal.

---

**DAILY LOG — output and micro-creation signal (if wired):**
If a daily-capture log exists (`[ROOT]/knowledge-store/daily.md` or wherever your connectors write it):
Entries are domain-tagged micro-outputs: things created, tried, thought, composed, cooked, written.
For each entry in the past 7 days:
- Note domain, date, and what was produced (not consumed)
- Distinguish output (wrote 3 lines of blog, recorded a phrase, tried a recipe variation)
  from consumption (watched a video, read a paper, did an exercise)
- Output entries compound over time — track accumulation toward publishable artifacts
If the daily log has entries not reflected in the connector/TRACKER: include them — they're real work.
If it is empty for a domain: note it — absence of micro-output is a signal worth surfacing.

2. `[ROOT]/mentors/profile.md`
   Note: energy patterns, behavioral patterns, calibration log, external teachers table.

3. `[ROOT]/mentors/season_current.md`
   Note: which domains are Active / Seeding / Silent. Locked external slots. Known disruptions.
   Season start date, season end date. Exit criteria per domain.

4. `[ROOT]/mentors/cross_domain.md`
   Note: all scheduling constraints, time-stacking opportunities, synergy bridges.

5. `[ROOT]/mentors/coordinator_state.md`
   Note: active cross-domain risks, capacity warnings, high-stakes register, active watches, calibration drift flags.
   This is the coordinator's own working memory. Carry every open item forward to Phase 3 step 3.5 for an explicit add/edit/close decision.

5a. **The memory file (always — the correction/fact/ask fix):**
   - `[ROOT]/mentors/MEMORY.md → LESSONS` — the correction memory (passed to every mentor agent in Phase 2).
   - `[ROOT]/mentors/MEMORY.md → FACTS` — binding facts + Never-Repeat list.
   - `[ROOT]/mentors/MEMORY.md → ASKS` — open-ask ledger. **Increment `Age` on every open row now.** Any row at Age ≥ 2 is an ESCALATION for Checkpoint 1; any row at Age ≥ 3 becomes a mandatory Mentor Challenge at Checkpoint 2 (Phase 3 step 3.4). This is mechanical — the coordinator does not get to decide an aged ask is fine.

6. **(Optional) cross-session memory index** — if your client exposes a global memory/auto-memory store, read its index and any `user`/`feedback` entries updated since the last review. These are upstream behavioral signals from *all* sessions (coding, writing, anything), a wider net than `profile.md`. Extract signals not yet in `profile.md` (learning style, communication preferences, new feedback patterns, life-context shifts). Note them separately; they feed Step 4f synthesis. Skip this step if your client has no such store.

**Step 1.3 — Compute dates**
```bash
date  # get today
```
Then compute:
- Past week: the Mon–Sun that just ended
- Next week: the Mon–Sun coming up
- Season week number (count from season start date in season_current.md)
- Weeks remaining in season (count to season end date)

**Step 1.4 — Identify active domains**
From season_current.md, list all domains with state = Active or Seeding.
These domains get a mentor agent in Phase 2. Silent domains are skipped.

**Step 1.5 — Build the WEEK_BRIEF**
This structured block is passed verbatim to every mentor agent.
Fill it in precisely — it is the only signal mentors have about what actually happened.

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
  Planned: [list tasks as scheduled]
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
Known disruptions next week: [travel, events, anything mentioned; write "none" if none]

OUTPUT CREATED THIS WEEK (source: daily log)
---------------------------------------------
[For each active/seeding domain:]
[DOMAIN]:
  Created: [list anything produced — blog lines, composition notes, recipe experiments,
           code notebooks, sketches, recordings, forum posts, etc.]
  Accumulated total: [if trackable — e.g. "blog draft: ~45 lines across 3 weeks"]
  If nothing: "no output" — this is signal, not shame.
[Omit domains with zero daily-log entries]

SEASON POSITION
---------------
Week [W] of [total weeks]. [X] weeks until season end ([end date]).
[If X <= 3: add "*** APPROACHING SEASON EXIT — mentors must evaluate exit criteria ***"]
```

---

### ⏸ CHECKPOINT 1 — SIGNAL BRIEF

**In `checkpoints` mode: post the signal brief (format below) as your response text, then pause for {{USER_NAME}}'s input (in Context A, call the client's question tool; in Context B, stop and wait). Do not proceed to Phase 2 until they answer. In `automated` mode: record this brief for the final report and proceed.**

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
e.g. "Harvard moved forward 3 times — evening cognitive load is the barrier"]

**Escalations (from MEMORY.md → ASKS):** [any Age ≥ 2 ask — name it and its owner. "none" if none.]

**Energy:** [1 sentence on morning vs evening execution split this week]

**Data quality:** [task connector ✓ / connector unavailable — signals from TRACKER.md only ⚠️]

**Question at Checkpoint 1 (checkpoints mode):**
"Anything to add before I consult the mentors? (Say 'looks good' or describe what I missed)"

---

**When {{USER_NAME}} replies:**
- "looks good" → proceed to Phase 2 with no changes.
- adds context → update WEEK_BRIEF with it, then proceed to Phase 2.

---

### PHASE 2 — PARALLEL MENTOR CONSULTATION
*Spawn all mentor agents in a SINGLE message (one agent/task call per domain, all in parallel).*

For each active/seeding domain identified in Step 1.4, spawn one agent using this template.
Replace [DOMAIN] and paste the full WEEK_BRIEF into the prompt.

---
**MENTOR AGENT PROMPT TEMPLATE:**

```
You are {{USER_NAME}}'s [DOMAIN] mentor — a domain expert. You have one job this week: give an
honest assessment of how their [DOMAIN] week went and produce the best [DOMAIN] plan for
next week. You do NOT own the overall schedule — the Coordinator does. Stay in your domain.

WEEK BRIEF FROM COORDINATOR:
[paste full WEEK_BRIEF here]

INSTRUCTIONS:
1. Run: find /sessions -name "profile.md" -path "*/mentors/*" -not -path "*/.git/*" 2>/dev/null | head -1
   Strip the filename to get [ROOT] base path. (If mounted at a stable path, [ROOT] is the notebook folder.)

1a. **READ THE MEMORY FILE FIRST (non-negotiable — this is the learning-loop fix).**
   - [ROOT]/mentors/MEMORY.md → LESSONS — the correction memory. Every RULE here is a pre-flight check you must pass. These are cross-domain: a lesson born in music binds you even if you are the finances mentor.
   - [ROOT]/mentors/MEMORY.md → FACTS — binding facts + Never-Repeat list. A plan conflicting with a fact is wrong by definition.
   - [ROOT]/mentors/MEMORY.md → ASKS — open asks (for awareness of anything your domain owns).
   This file is small and MUST be loaded before you draft anything. Recurring errors happen precisely because corrections lived in files the mentor never read.

2. Read [ROOT]/mentors/profile.md — the DURABLE sections in full: Identity, Time Reality, What Motivates/Demotivates, Accountability Style, **Behavioral Patterns (cross-domain)** (the core undated laws — read this in full, it is load-bearing), Learning Style, Communication Preferences, External Teachers, and the Calibration Log SUMMARY. The long dated "Behavioral Patterns — W-N additions" changelog at the END of the file (if present) is on-demand: skim it only for entries tagged to YOUR domain, since the WEEK_BRIEF carries this week's behavioral inferences. (This file is re-read by every agent; reading the durable core instead of the full dated changelog is a large, safe token saving — but the undated cross-domain Behavioral Patterns section is part of the core, not the changelog.)

   **READ-SCOPING (cost discipline — read the slice, not the whole file).** The files below grow with the system's age; reading them in full every week is the dominant token cost and most of it is irrelevant to next week's plan. Read scoped:

4b. Read [ROOT]/mentors/[DOMAIN]/current_focus.md IN FULL FIRST
   — mentor's working memory: current phase, in-progress topic, next planned, calibration flags. This is small and tells you exactly which slice of the larger files you need. Read it before curriculum/log so you know what to slice to.

3. Read [ROOT]/mentors/[DOMAIN]/curriculum.md — CURRENT PHASE SECTION ONLY.
   Jump to the phase/section current_focus.md names as the current position; read that section plus the next one (lookahead). Do NOT read the whole curriculum unless current_focus is missing/ambiguous.

4. Read [ROOT]/mentors/[DOMAIN]/log.md — CURRENT PHASE SLICE ONLY.
   Read from the most recent `## Phase <N>` header downward. If no phase headers exist yet, read the last ~40 lines. Deeper history is on-demand only. (This is the P8 read-cost-bounding discipline.)

4a. Read [ROOT]/mentors/[DOMAIN]/done_topics.md
   — the catalog (small). Verify no upcoming recommendation overlaps a completed topic (P1 fix).

5. Read [ROOT]/mentors/[DOMAIN]/intel.md ONLY IF its top-of-file "Last updated" is within ~14 days OR current_focus flags new intel.
   Otherwise skip it — stale intel read every week is pure waste.

6. Cross-reference the WEEK_BRIEF completion data against curriculum.md expected position.
   If TRACKER.md completions and log.md disagree, trust TRACKER.md as the source of truth.

7. CRITICAL THINKING PASS — do this BEFORE writing your report.
   You are an expert mentor, not a yes-man. {{USER_NAME}}'s comments are signal, not gospel.
   Some are genuine insight. Some are comfort-seeking disguised as valid criticism.
   Your job is to find the OPTIMAL path to their goals, which sometimes means holding the
   line when they want to retreat, and sometimes means listening when they want to pivot.

   a) SIGNAL TRIAGE — For each of {{USER_NAME}}'s comments in the WEEK_BRIEF, classify it:
      - GENUINE INSIGHT: Has reasoning + consistent with growth trajectory → accept and adapt
      - COMFORT-SEEKING: No reasoning beyond preference, correlates with difficulty increase,
        or contradicts established goals → flag it, hold the line, propose minimum viable version
      - LEGITIMATE PIVOT: Has reasoning, even if it contradicts prior plan → accept, document why
      - NOISE: Emotional, one-off, context-dependent → note but don't change plan
      Key heuristic: reasoning + pattern history. A comment with reasoning that's consistent
      with behavioral patterns = trust it. A comment without reasoning that appears right when
      difficulty spikes = challenge it. Check log.md for prior similar requests and their outcomes.
      IMPORTANT: {{USER_NAME}}'s principled refusals (detailed reasoning, identifies specific failures)
      are NOT comfort-seeking. See profile.md "Principled refusal ≠ avoidance" pattern if present.

   b) DEVIL'S ADVOCATE — For each recommendation you plan to make in NEXT_WEEK_GOALS:
      - State the strongest counter-argument (why this might be wrong or suboptimal)
      - If the counter-argument is stronger, change your recommendation
      - If it's not, note why your recommendation stands
      This forces you to stress-test your own output. If you can't articulate a counter-argument,
      you haven't thought hard enough.

   b2) THE NON-OBVIOUS MOVE (creativity-forcing — required, not optional).
      Before finalizing NEXT_WEEK_GOALS, generate exactly THREE candidate moves for this domain
      this week that a checklist would never produce, then keep the best ONE:
      - A high-agency move: what would a world-class mentor in this domain do that {{USER_NAME}}
        can't yet see? (a cross-domain bridge, a leverage point, an unconventional resource,
        a way to turn a blocker into the lesson).
      - Judge the three against: does it sit at/above the ~70% edge, does it produce a tangible
        output, is it non-obvious, does it respect FACTS/LESSONS.
      - Put the winner in NEXT_WEEK_GOALS and record all three (winner + 2 rejected, one line each)
        in the THREE_MOVES report field. "No creative move this week" is itself a flag — the
        top recurring complaint in this system is "weakly planned / no creativity"; a checklist-only week fails.

   c) HISTORICAL PATTERN GATE — Before accepting any comment that implies a plan change:
      - Check log.md: has a similar request appeared before? What happened after?
      - Check profile.md behavioral patterns: does this fit an established avoidance pattern?
      - Check timing: is this request coinciding with a difficulty increase in the curriculum?
      If 2+ of these flags fire → do NOT silently comply. Flag it in CRITICAL_SIGNALS as
      "needs_discussion" so the Coordinator surfaces it to {{USER_NAME}} at Checkpoint 2.

8. Return EXACTLY the structure below. No prose outside these labelled sections.
   All fields are required. Write "none" if a field has nothing to report.

---

## [DOMAIN] MENTOR REPORT

**PREFLIGHT** *(answer every MEMORY.md → LESSONS pre-flight in one line each — pass, or fail+fix. A report missing this section is incomplete and must be regenerated. This is the mechanism that makes a week-N correction change week-N+1 behavior. If LESSONS is still empty, write "no lessons yet" and skip to the NEW-correction line.)*
- [one line per active lesson: L# name → pass / fail+fix]
- (Any NEW correction from {{USER_NAME}} this week → state the lesson to add to MEMORY.md → LESSONS.)

**THREE_MOVES** *(the creativity-forcing output — winner + 2 rejected, one line each)*
- WINNER: [the non-obvious move going into NEXT_WEEK_GOALS]
- rejected: [move 2] · [move 3]

**WEEK_ASSESSMENT**
[2–3 sentences. Honest. No cheerleading. What actually happened, what the trend is,
whether this week represents progress or regression vs prior weeks.]

**CURRICULUM_POSITION**
[e.g. "Phase 0, Week 2. On track." or "Phase 0, Week 1. 2 sessions behind — content not started."]

**GAP_ANALYSIS**
[Specific counts: "Yoga: 2/2 ✅  Run: 0/2 ❌  Strength circuit: 1/2 ⚠️"]

**DIFFICULTY_SIGNAL**
[Based on what's getting done vs skipped: too easy / right level / too hard.
One sentence. Include a specific adjustment recommendation if calibration is off.]

**CRITICAL_SIGNALS**
[Output of the Critical Thinking Pass (instruction step 7). Required sections:]

Signal triage:
[For each {{USER_NAME}} comment in WEEK_BRIEF, one line:]
- "[quote]" → [GENUINE INSIGHT / COMFORT-SEEKING / LEGITIMATE PIVOT / NOISE] — [1-line reasoning]
[If no comments this week: "No comments to triage."]

Devil's advocate on my recommendations:
[For each NEXT_WEEK_GOAL below, one line:]
- [Goal]: Counter: [strongest objection]. Stands because: [why it's still right] / Changed to: [revised goal]

Flags for Checkpoint 2: [needs_discussion / none]
[If needs_discussion, state the specific question for {{USER_NAME}} in plain language.]

**NEXT_WEEK_GOALS**
[3–5 items. Required specifics: exact day, time-of-day, what to do (not generic),
duration, and one-line reason why this particular thing.]
- [Day] [morning/afternoon/evening]: [exact task with measurable specifics] ([duration]) — [why]
- ...

**VALUE_CHECK** *(value, not completion, is the headline metric)*
[For last week's tasks: tag each landed-at-edge / done-but-low-value / bogus-or-misdirected —
set by {{USER_NAME}}'s comment when present, mentor-judged when silent. A task completed but
bogus is a SYSTEM miss, not a win; a domain at 100% completion with a bogus flag is NOT "on track."]

**OUTPUT_ASSESSMENT**
[What did {{USER_NAME}} create/produce in this domain this week? (from the daily-log OUTPUT section)
If something was produced: acknowledge it, note quality/direction, suggest next micro-step.
If nothing: propose ONE specific micro-output target for next week — something achievable
in 2-5 minutes daily that compounds over time. The target must be so small it feels trivial —
that's the point. Over weeks, these accumulate into publishable artifacts.
IMPORTANT: each micro-output is its OWN named task stacked on an existing anchor — never a
single anonymous "daily micros" catch-all (buried catch-alls don't execute).]

**CURRICULUM_ADAPTATION**
[Based on: (1) current position in curriculum.md, (2) log.md execution data,
(3) intel.md latest findings, and (4) output assessment — what should change?
This is the LIVING CURRICULUM mechanism. Propose specific, concrete changes (resource swaps,
pacing changes, new additions from intel, difficulty adjustments, output integration).
Also confirm the curriculum is factually correct and internally coherent for the user's ACTUAL
position — do not conflate distinct tracks; make no false factual claims ("X is on your exam").
Write "no change" only if curriculum is perfectly calibrated. Default assumption: something
can always be improved.]

**NETWORK_NOTE**
[One person, community, or group worth being aware of in this domain.
Not an action item — just awareness. Write "none" if nothing new this cycle.]

**CONCERNS_FOR_COORDINATOR**
[Scheduling dependencies this domain has. Cross-domain flags. Anything the coordinator
must know to avoid conflicts or enable synergies. Write "none" if none.]

**LOG_ENTRY**
[Write the complete log.md entry for this past week, formatted to match existing entries
in this domain's log.md exactly. This will be appended to log.md verbatim.]

**CURRICULUM_UPDATE**
[yes — [specific change to make] / no]
```
---

---

### PHASE 3 — SYNTHESIS AND CONFLICT RESOLUTION
*After all mentor agents return.*

**Step 3.1 — Time budget check**
Sum total time requested by all mentors for each weekday.
- If total ≤ `TIME_CEILING_PER_DAY` on a given weekday: proceed.
- If over budget: identify the lowest-intensity domain for that day (use season_current.md
  domain intensities: High > Medium > Low). Send that mentor one targeted follow-up agent:
  "On [day] you requested [X] min. Total across all domains is [Y] min, ceiling is [ceiling] min.
  You have [Z] min. Keep your single highest-priority goal for that day. Drop the rest."
- Maximum one additional round per domain.

**Step 3.2 — Slot conflict check**
Check if two domains claim the same locked time slot.
If conflict: send back to the lower-priority domain with: "The [slot] on [day] is taken by
[domain]. Revise your plan — that slot is unavailable."

**Step 3.3 — Cross-domain integration**
Review all CONCERNS_FOR_COORDINATOR fields from mentor reports.
- Apply time-stacking where possible (e.g., walk + audiobook = Fitness + Reading in one slot)
- Resolve dependencies (e.g., teacher confirmed → update that domain's plan accordingly)
- Flag any behavioral concerns worth surfacing to {{USER_NAME}} in Phase 5

**Step 3.4 — Collect critical signals**
Review all CRITICAL_SIGNALS sections from mentor reports.
- Collect every flag marked "needs_discussion" — these become Mentor Challenges at Checkpoint 2.
- **ASKS escalation (mechanical):** any MEMORY.md → ASKS row at Age ≥ 3 is a MANDATORY Mentor Challenge this week — present why it keeps failing and propose a structural change (drop / change owner / change approach). It may not be silently carried. Any row at Age 2 is escalated to a named existing-mentor owner with a specific weekly deliverable.
- **PREFLIGHT audit:** scan every mentor report's PREFLIGHT section. Any "fail" that wasn't fixed, or any report missing the section, is sent back for one regeneration round. Any NEW lesson a mentor proposed → stage it for Phase 4 write to MEMORY.md → LESSONS.
- If multiple mentors flag the same behavioral pattern, consolidate into a single cross-domain challenge.
- Also apply the coordinator's own critical eye: if a mentor's signal triage seems wrong
  (e.g., classified a comment as GENUINE INSIGHT but profile.md shows a recurring avoidance pattern),
  override and flag it.
- The coordinator is the final filter. Only surface challenges that genuinely need {{USER_NAME}}'s input.

**Step 3.5 — Update `coordinator_state.md`**
The coordinator carries its own state file (`mentors/coordinator_state.md`) — between-domain attention that no single mentor owns.
- Re-read the version loaded in Phase 1 step 1.2.
- For each section (Cross-Domain Risks, Unresolved Trade-Offs, Capacity Warnings, High-Stakes Register, Calibration Drift, Active Watches): add new items surfaced this week, edit existing items whose state changed, move closed items to *Resolved this period*.
- Active Watches auto-clear at the end of each review unless re-flagged. Re-flag the ones still active.
- Append one line to the Revision Log: date + 1-sentence summary of what changed.
- Hard size cap: ~200 lines. If approaching, flush *Resolved this period* contents to `mentors/coordinator_history/<YYYY>.md` (create file if missing).
- This update happens BEFORE Checkpoint 2 — so the proposed plan reflects the freshly-updated coordinator state.

**Step 3.6 — Run the SELF-VERIFICATION PASS** (the checklist is defined in the "SELF-VERIFICATION PASS" block that appears just before Phase 5 — scroll to it). Run it now against the proposed plan; fix anything it flags before Checkpoint 2.

---

### ⏸ CHECKPOINT 2 — PLAN APPROVAL

**In `checkpoints` mode: post the proposed plan (format below), then pause for {{USER_NAME}}'s approval. No files are written and no connector tasks are touched until cleared. In `automated` mode: record the plan for the final report and proceed to Phase 4.**

Format:

---
**Proposed plan for Week [W+1] — [Next Mon] – [Next Sun]**
*[Any mentor concerns or flags worth knowing before you decide]*

[ONLY if Step 3.4 produced any needs_discussion flags:]
**Mentor Challenges — your input needed before finalizing:**

[Number each challenge. Present as a direct question from the mentor to {{USER_NAME}}.
Include: which domain, what the mentor observed, what they recommend, and what they
need {{USER_NAME}} to weigh in on. Keep each challenge to 3–4 sentences max.
Max 3 challenges per week. Any Age ≥ 3 ask from Step 3.4 is one of them.
If no flags: omit this section entirely.]

---

**Monday [date]**
- [domain]: [task] ([duration])

**Tuesday [date]**
...
[continue Mon–Sun. Max 3 tasks per day. Written as {{USER_NAME}} will see them in the connector.]

**Micro-output targets this week:**
| Domain | Target | Accumulates toward |
|--------|--------|--------------------|
| [domain] | [2-5 min daily micro-output] | [eventual artifact] |

**One thing to protect:** [single most important commitment]
**One thing to watch:** [single behavioral signal to monitor]

**Question at Checkpoint 2 (checkpoints mode):** "Approve this plan for next week? (Or respond to the challenges / describe changes.)"

---

**When {{USER_NAME}} replies:**
- "looks good" / "mentors are right" → proceed to Phase 4 with no changes.
- responds to challenges → apply their responses. If a response provides genuine reasoning the
  mentor didn't have, accept it and adjust. If it is itself comfort-seeking (no new reasoning,
  just restating preference), note it in profile.md behavioral patterns but still respect the
  decision — they are the principal, not the mentors. One round only.
- requests changes → apply them, proceed to Phase 4. One round only.

---

### PHASE 4 — WRITE OUTPUTS
*Run the writes sequentially. Only execute after Checkpoint 2 is cleared (checkpoints mode) or straight through (automated mode).*

**Step 4a — Task connector: wipe and rewrite (if connected)**

All connector signals were already captured in Phase 1 — including unfinished and overdue tasks.
By the time this step runs, every signal has been read, synthesised into WEEK_BRIEF,
seen by mentor agents, and incorporated into the approved plan. Only now is it safe to wipe.

1. **Delete all existing tasks**: fetch all open tasks, delete them entirely.
   The connector is not the long-term record — TRACKER.md / the notebook is. Deleted tasks are not
   lost; their signals are already in WEEK_BRIEF and will be written to log.md and TRACKER.md.

2. **Write next week clean**: create one task per planned session (Mon–Sun).
   - **Task title**: "[Domain]: [specific what to do]" · due date = correct date · duration if supported. Use domain labels/projects if established. Max 3 tasks per day.
   - **Task description is MANDATORY and must be self-contained.** A title is a label, not an instruction. Each description carries, sourced from the domain's `curriculum.md` / `current_focus.md` / mentor report (NOT invented, NOT compressed to a slogan):
     - **WHAT** — the concrete action, with the specific lesson/chapter/dataset/number named.
     - **WHY** — one line on what this builds toward (the curriculum/season link).
     - **HOW** — the actual steps, including any primer needed to understand a term used (define acronyms; a task may not reference a concept the description doesn't explain).
     - **DONE WHEN** — explicit completion criteria.
   - **Domain rules are binding here.** Honour each domain's calibration rules from `current_focus.md`.

3. **VALIDATION GATE (reject before writing).** For every task, check: (a) Could it be completed by a single AI query in <10 min as a standalone? → it's a retrieval task; fold it into a harder exercise or cut it. (b) Does the description define every term it uses? → if not, add the primer. (c) Does it state DONE-WHEN? → if not, add it. (d) Does it contradict a MEMORY.md → FACTS line or a Never-Repeat item, or re-propose done work? → cut it. (e) Does it violate a domain rule? → fix or cut. A task that fails the gate does not get written.

Result: the connector contains exactly next week's plan, every task self-contained and gate-passed. Nothing else.

If no task connector: skip this step, note it in Phase 5.

**Step 4a.1 — Write WEEK_BRIEFING.md (the primary read surface)**
Write `[ROOT]/WEEK_BRIEFING.md`: the full expert briefing {{USER_NAME}} reads alongside the checklist. One section per task, grouped by day, each with WHAT / WHY / HOW (step-by-step, with primers) / DONE WHEN / TIME. This is where mentor expertise lives at full fidelity — the connector task description is the compressed carry, this is the source. Lead with the week theme + locked slots. Overwritten each week (this-week-only; TRACKER.md holds history).

**Step 4b — Update each domain's log.md**
For each mentor report: append the LOG_ENTRY field verbatim to `[ROOT]/mentors/[domain]/log.md`.
Do not edit or reformat. Append only — never overwrite existing entries.

**Step 4b.1 — Update each domain's done_topics.md and current_focus.md (the P1 fix in action)**
For each mentor report:
1. For every session listed in the LOG_ENTRY for this past week, append a row to `[ROOT]/mentors/[domain]/done_topics.md` if not already present. Update *Last updated* and refresh *Next uncovered topics* from curriculum position.
2. Refresh `[ROOT]/mentors/[domain]/current_focus.md`: update `In progress`, `Next planned`, `Last calibration check` = today, and any calibration flags from the CRITICAL THINKING PASS.

**Step 4b.2 — Run DRIFT_CHECK per active domain**
Run the DRIFT_CHECK protocol (in `framework/PROTOCOLS.md`) for each active or seeding domain. Surface findings in the Phase 5 presentation.

**Step 4b.3 — Update the memory file (the loop that makes the system learn — do this every review)**
1. **MEMORY.md → LESSONS** — For every NEW correction {{USER_NAME}} gave this week (a "bogus"/"mundane"/"weakly planned" rebuke, a factual error caught, a declined item), add a lesson or increment the violation count of the lesson it maps to. If any adopted lesson was violated this week, increment its count; **if a count reaches 2, the prose fix has failed — escalate it to a STRUCTURAL change (protocol/curriculum/format edit) and note the escalation.** No correction leaves the review unrecorded.
2. **MEMORY.md → FACTS** — Add any fact {{USER_NAME}} stated this week that contradicts a system assumption or closes a direction; add any declined item to Never-Repeat. Edit superseded facts in place (never two versions).
3. **MEMORY.md → ASKS** — For any ask closed this week: move it to the Closed table WITH the shipped artifact named and {{USER_NAME}}-confirmed (self-declared resolution is prohibited). For asks escalated: record the new owner + named deliverable. New asks stated this week get a new row at Age 0.

**Step 4c — Update TRACKER.md (if you keep one)**
In `[ROOT]/TRACKER.md`: move "Next Week" → "This Week"; write a new "Next Week" (Mon–Sun) from the cohesive plan with time-stacking applied; append a one-paragraph summary of this past week to "Weekly Completions". (Skip if you don't keep a TRACKER.md — WEEK_BRIEFING.md + the connector + logs already hold the plan.)

**Step 4d — Update season_current.md**
Append to "Known Disruptions Log" if any disruptions occurred; update the Domain States table track note if a domain is significantly off-track; add any new locked slots confirmed this week to "External Schedule Anchors".

**Step 4e — Apply curriculum adaptations**
For each mentor report with CURRICULUM_ADAPTATION ≠ "no change": read `[ROOT]/mentors/[domain]/curriculum.md`, apply the specific change, and add a dated comment at the change site: `<!-- Adapted [date]: [reason] -->`. This is how curriculum stays alive.

**Step 4f — Update profile.md (synthesis from all signal sources)**
Synthesise signals: cross-session memory (if read in 1.2 step 6, wide net) + connector/TRACKER (this week's execution) + mentor reports (domain observations).
1. From cross-session memory: for each signal not yet in profile.md that is relevant to how mentors should teach {{USER_NAME}}, add/update the relevant section (Learning Style, Behavioral Patterns, Communication Preferences). Translate into mentor-usable language; don't copy verbatim.
2. From this week's execution: if a behavioral pattern appeared for 2+ consecutive weeks and isn't documented, add it to "Behavioral Patterns".
3. From mentor reports: append any difficulty signal to the Calibration Log; add any confirmed external teacher to the External Teachers table.

**Step 4g — Year archive (only if this is the first WEEKLY_REVIEW of a new calendar year)**
For each domain that had session activity in the year just ended, write `[ROOT]/mentors/<domain>/archive/year_<YYYY>.md` using the year-archive template in `templates/domain/README.md`. Skip entirely on any other week.

**Step 4h — (Optional) Commit the notebook.** Sync is optional and never blocks the review. If you keep the notebook in git, run `scripts/sync.sh "review: W[N] weekly review (approved)"` or `git add -A && git commit`. See `framework/PROTOCOLS.md` → "Keeping your notebook in git (optional)".

---

### SELF-VERIFICATION PASS (run at the END of Phase 3, before Checkpoint 2)
*Fast, mechanical, ~30 seconds. Catches the class of errors {{USER_NAME}} would otherwise have to catch. Runs on the PROPOSED plan before it is shown at Checkpoint 2, so errors are fixed before they see them — not after.*

The coordinator runs this checklist against the proposed plan and writes:

```
SELF-CHECK (W[N])
- FACTS conflict: [none / lists any task contradicting a MEMORY.md → FACTS line]
- Never-Repeat: [none / names any declined item that slipped in]
- Locked slots: [all honored / lists any conflict or inversion]
- done_topics overlap: [none / names any already-done work re-proposed]
- Progressive overload: [each domain harder-or-equal vs last week? / names any step-down]
- PREFLIGHT: [all reports passed / lists any unresolved fail]
- ASKS ages: [no aged ask ignored / lists any Age≥3 not surfaced]
```

If any line is non-empty, fix the plan and re-run the check before Checkpoint 2 / presentation. This pass is the difference between the system catching its own errors and {{USER_NAME}} catching them after the fact.

### PHASE 5 — PRESENT TO {{USER_NAME}}
*Clean, phone-readable. No file paths. No implementation details.*

Present this structure:

---
**WEEKLY REVIEW — Season [N], Week [W]**
*[Past Mon]–[Past Sun] → [Next Mon]–[Next Sun]*

**How the week went:**
[2–3 honest sentences. Surface the real pattern — what was consistent, what was dropped,
what the trend means. Not cheerleading.]

**Domain snapshot:**
| Domain | Status | Key signal | Value | Output this week |
|--------|--------|------------|-------|-----------------|
| [domain] | [On track / Slightly behind / Behind / Concern] | [1 specific line] | [landed / low / bogus] | [what was created, or "—"] |
[one row per active/seeding domain]

**Micro-output targets (2-5 min/day):**
| Domain | This week's target | Building toward |
|--------|-------------------|-----------------|
| [domain] | [specific tiny daily action] | [eventual artifact] |

**Next week:**
[Mon–Sun plan. Each day: list domains + tasks + duration, max 3 tasks/day.
Short enough to read on a phone in 2 minutes.]

**One thing to protect:**
[The single most important commitment that cannot slip. One sentence.]

**One thing to watch:**
[The single behavioral signal or risk worth monitoring this week. One sentence.]

---
