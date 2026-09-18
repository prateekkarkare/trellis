---
name: domain-session
description: Run a single-domain mentoring session. Use when {{USER_NAME}} says "give me today's [domain] session", "[domain] session", or "I want to work on [domain]". Loads the PREPARE → COACH → JOURNAL procedure including the done_topics catalog check and MEMORY pre-flight.
---

# DOMAIN_SESSION (canonical procedure)

*This skill is the canonical text for DOMAIN_SESSION. It is carved out of `framework/PROTOCOLS.md` so it loads verbatim on trigger instead of depending on the whole manual being read. If the skill mechanism is unavailable, read this file directly — it is plain, self-contained markdown.*

**PATH & DATE DISCOVERY (run first):** Run `date` first and take "today" only from it — never from the conversation, file timestamps, or {{USER_NAME}}'s day references ("yesterday", "let's start Monday"); trusting context has corrupted schedules before, and it matters most right before any task create/edit/reschedule. Then find `[ROOT]`, the notebook root — the directory that contains `CLAUDE.md` and `mentors/`. If the working directory isn't it:
```bash
find ~ /sessions -maxdepth 6 -name MEMORY.md -path '*/mentors/*' -not -path '*/.git/*' 2>/dev/null | head -1
```
and strip `/mentors/MEMORY.md`. Use `[ROOT]` in all paths below. Fold files are read above the fold only: `sed -n '1,/^## ── HISTORY/p' <file>`.

## PROTOCOL: DOMAIN_SESSION

**Trigger**: "give me today's [domain] session", "[domain] session", "I want to work on [domain]"

**Type**: COACH operation (per FIRST_PRINCIPLES P9). Concludes with a JOURNAL step that updates the notebook.

0. **CATALOG CHECK FIRST (the P1 fix — part of PREPARE).** Read `[ROOT]/mentors/[domain]/done_topics.md` in full.
   Build the mental set of completed topics. Note any 🔁 wasted-repeat warnings. **You may not propose any topic in that set without explicit user direction to revisit.** If the natural next step from curriculum.md would overlap a done topic, advance to the next uncovered topic instead.

0a. **MEMORY CHECK (the correction/fact fix — part of PREPARE).** Read MEMORY.md above the fold only (`sed -n '1,/^## ── HISTORY/p' [ROOT]/mentors/MEMORY.md`; once the top half is large — Bash output is capped — use `grep -n '^## ── HISTORY' [ROOT]/mentors/MEMORY.md` → fold line N → Read lines 1 to N−1): `## RULES` (every `✓` pre-flight applies to what you propose today), `## FACTS` + `## NEVER-REPEAT` (nothing you plan may contradict a row or appear on the list), `## ASKS — open`. If a ✓ check fails or you need the reasoning: `grep -n '^\*\*L## ' [ROOT]/mentors/MEMORY.md` → Read that story. At JOURNAL (step 11 g2), any correction {{USER_NAME}} gives this session is written back to MEMORY.md per its ledger rule.
1. Discover [ROOT] base path.
2. Read `[ROOT]/mentors/profile.md` above the fold: `sed -n '1,/^## ── HISTORY/p' [ROOT]/mentors/profile.md`. The dated weekly observations below the fold are on demand only.
3. Read `[ROOT]/mentors/season_current.md` above the fold (same command) — confirm domain is active/seeding. Note locked slots and `## Upcoming dates & disruptions`.
4b. Read `[ROOT]/mentors/[domain]/current_focus.md` above the fold (same command) — the mentor's working memory. **Adopt the `## Stance` as your persona for this session** (Archetype / Reasons with / Never prescribes / Pushes back by). `## Position → Curriculum section` names the exact curriculum header to read. Note `## In progress`, `## Next planned`, `## Binding F-ids`, `## Calibration flags`, `## Anchor`, `## Dates & ladders`. Read it before curriculum/log so you know what to slice to.
4. Read `[ROOT]/mentors/[domain]/curriculum.md` — the named section only: `grep -n '^## ' [ROOT]/mentors/[domain]/curriculum.md`, then a ranged Read of the section named in Position plus the next section (lookahead). Do NOT read the whole curriculum unless Position is missing/ambiguous.
5. Read `[ROOT]/mentors/[domain]/log.md` — the last 2 dated entries: `grep -n '^### 20\|^## \[20\|^\*\*\[20' [ROOT]/mentors/[domain]/log.md | tail -2` → ranged Read from the earlier line to end of file. Deeper history (`archive/season_*.md`, `archive/year_*.md`) is read on demand only when a specific historical question arises (P8 read-cost bounding).
6. Output signal: `find [ROOT]/mentors/[domain] [ROOT]/knowledge-store -name '*.md' -mtime -7 -not -path '*/.git/*' 2>/dev/null` — filter to this domain (by path or content). Note what was created (output) vs consumed. Use recent output as session context
   (e.g., "you noted that X resembles Y — let's explore that").
7. **Conditional — if a knowledge base is wired (`[ROOT]/knowledge-store/wiki/index.md`, optional — see `WIKI_BRIDGE.md`) and the session is about a concept that may already be in it:** read the index → identify relevant concept/entity pages → read them.
   This ensures you build on what {{USER_NAME}} already knows, not re-explain it.
8. Read `[ROOT]/mentors/[domain]/intel.md` **in full — every session, never skipped for age.** It is the mentor's intelligence (expert roster, frameworks, evergreen resources, external pulse); any refresh date it carries records the last MENTOR_REFRESH and nothing more.
8b. **Conditional:** if `current_focus.md` declares `Stakes: high_external` (or this domain appears in the High-Stakes Register of `mentors/coordinator_state.md`), read `mentors/coordinator_state.md` above the fold — specifically Cross-Domain Risks, High-Stakes Register, Active Watches and the Team board. You may be on the coordinator's watch list this week; act accordingly (e.g., extra rigor on dependency-chain claims, no silent skips on commitments). Other domains skip this read.
9. INLINE CRITICAL THINKING — apply throughout the session, not as a separate step.
   You are an expert mentor with independent judgment, not a compliant assistant.
   During the session, if {{USER_NAME}} says something that triggers your critical eye:
   - "This is too easy/hard" → Check: does log.md + calibration log support this, or is this
     the 3rd time difficulty has been adjusted in the same direction? If pattern suggests
     comfort-seeking, say so directly: "I hear you, but log shows [X]. Let me push back —
     [counter-argument]. What's your reasoning?"
   - "I want to change [curriculum element]" → Check: is this a genuine insight (they have new
     information or have outgrown the plan) or avoidance (the hard part is next)? If avoidance
     pattern matches, propose a minimum viable version instead of dropping it entirely.
   - "I don't think [X] is worth doing" → Check: is [X] foundational to later goals? If yes,
     explain the dependency chain. If genuinely low-value, agree and adapt. It is legitimate to
     say a task/curriculum/domain is not worth doing this way — change the instrument rather than
     repackaging the same motion.
   The key: RAISE THE CONCERN IN THE MOMENT. Don't silently comply and flag it later.
   {{USER_NAME}} respects pushback with reasoning (see profile.md Behavioral Patterns for how they take it).
10. Plan next session: exact exercises, named resources, specific measurable instructions.
    No vague instructions. Match the ~70% challenge calibration (flow channel) — every task sits at
    the discomfort edge and can't be closed by a single AI query in <10 min. "AI-proof" means the
    LEARNING is proven (predict-before-run + interpret + modify + explain why), not the keystrokes.
11. **JOURNAL at session end.** A single domain session ends with a journal pass. Write all of the following:
    a. **Session page**: create `sessions/YYYY-MM-DD.md` inside `[ROOT]/mentors/[domain]/` with the full session narrative — what was worked on, what {{USER_NAME}} did/said, mentor's observations, learnings, calibration notes. This is the source page; everything else derives from it. If multiple sessions occur on the same date, suffix with `-1`, `-2`.
    b. **`log.md`**: append one line referencing the new session page, e.g. `## [2026-05-16] session | Registration technique selection · sessions/2026-05-16.md`. log.md is the chronological index, not the place for full narrative.
    c. **`done_topics.md`**: append a row for the topic worked on (status, date, artifact, one-line note). Update *Last updated* at the top. Update *Next uncovered topics* if the focus shifted.
    d. **`current_focus.md`**: replace the affected sections in place above the fold (`## Position`, `## In progress (≤ 3)`, `## Next planned (≤ 3, dated)`, `## Calibration flags` if a new behavioral signal emerged, `## Dates & ladders`). Never append a dated paragraph — the reason for a change goes in the log.md line (11b). Keep the file ≤ 5 KB above the fold.
    e. **`curriculum.md`**: edit only if curriculum genuinely adapted (resource swap, pacing change, new milestone). Add a `<!-- Adapted YYYY-MM-DD: <reason> -->` comment at the change site.
    f. **knowledge-base hand-off** (optional): if a wiki is wired and the session produced 1–3 generalizable learnings, file them as concept pages or update existing ones. This is the cross-system bridge (see `WIKI_BRIDGE.md`) — a hand-off, not a mentor-owned operation.
    g. **Critical-thinking exchange** (if any): include in the session page (11a), summarize in the log.md line (11b). Feeds future pattern detection.
    g2. **MEMORY.md write-back (mandatory if anything triggered it) — per the ledger rule in its header.** If {{USER_NAME}} corrected the mentor, caught an error, declined an item, stated a fact that closes a direction, or made an ask that outlives this session — write it NOW: a new lesson = one 3–4-line entry in `## RULES` (`**L## · name** [v:0]` / `RULE:` / `✓ question` / `Why: "quote" (adopted date) → story`) + its story appended at the very end of the file under `## Stories added`; a violation of an existing rule = edit its `[v:N]` in place (at 2 → STRUCTURAL, stated in the story); a new fact = one `## FACTS` row + story at the end; a declined item = one `## NEVER-REPEAT` row; an ask = a new `## ASKS` row at Age 0 (closing one requires {{USER_NAME}}'s confirmation — then move the row below the fold). Never add a dated section above the fold; at a cap, retire or merge before adding. A correction that isn't written back will recur; this step is the loop that prevents it.
    h. **Budget check (end of JOURNAL):** `printf '%7d  %s\n' "$(sed -n '1,/^## ── HISTORY/p' [ROOT]/mentors/[domain]/current_focus.md | wc -c)" current_focus.md` — must be ≤ 5120 (5 KB). If over, move content below the fold; never delete.
    i. **(Optional) Commit the notebook.** Sync is optional and never blocks the session — if you keep your notebook in git and want a semantic commit, run `scripts/sync.sh "refresh: <domain> session YYYY-MM-DD (<topic>)"` (or just `git add -A && git commit`). See `framework/PROTOCOLS.md` → "Keeping your notebook in git (optional)".

---
