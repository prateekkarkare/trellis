# {{WORKSPACE_NAME}} — First Principles

*The constitution for the mentor system. Survives any redesign. Update only after deliberate reflection.*
*Adopted: 2026-05-16.*

This system is supposed to mimic a team of expert human mentors guiding {{USER_NAME}} across many domains over many years. It needs to last longer than the history of most software. So we ground every architectural decision on the principles below, not on patches.

Every future proposal must be checked against these. If a proposal violates a principle, it doesn't ship — we either revise the proposal or revise the principle deliberately.

---

## P1. Markdown prose is the source of truth. Everything else is derived.

Caches, indices, structured extracts are disposable. The prose in `log.md`, `curriculum.md`, `profile.md`, wiki entries — that is the irreplaceable record. A schema can be revised, regenerated, deleted. A paragraph written in 2026 cannot be reconstructed from anything else.

## P2. The user writes by talking. The mentor writes the files.

The user's interface is the chat with a mentor LLM. The user never opens a CLI, never fills out a form, never edits structured fields. The mentor reads context, has the conversation, and writes all artifacts (prose, catalog updates, current-focus updates). Friction on the user side is the system's worst failure mode — friction kills longevity.

## P3. The LLM mentor does the bookkeeping, not the user.

A human mentor keeps their own notes about their student. They don't hand the student a form after each session. The mentor (LLM) is responsible for reading all relevant prose at session start, having the conversation, and writing all updates at session end. If a mentor forgets, the next mentor reads everything from scratch and remembers.

## P4. Schemas are ephemeral. The prose substrate is permanent.

Schema v1 → v2 → v7 is fine. `log.md` from 2026 will be readable in 2056 by tools nobody has invented yet, the same way a 1969 Unix text file is readable today. PyYAML may not exist in 2046; markdown will. Do not bet system longevity on any specific tool, library, or format other than plain text and git.

## P5. Minimize structural dependencies. Maximize prose.

The durable layer is **plain text + filesystem + git**. Everything else is a tool that can disappear without losing data. If we lose PyYAML, Python 3, every CLI in `tools/` — we lose nothing. The mentor reads the prose and rebuilds whatever structure is wanted.

## P6. Validators measure cache-vs-prose health, not user discipline.

When derived state drifts from prose, the prose wins. Drift means "the derived view is stale and should be regenerated", not "the user failed to log properly". The user never bears the cost of cache maintenance.

## P7. The human-mentor metaphor is the test.

Before adding anything to the system, ask: *would a human mentor demand this of their student?* If no, don't build it.

A real mentor DOES ask about things like difficulty, duration, what felt easy or hard, what got skipped and why. These are core coaching signals — every gym trainer asks "how was that, 1–10?" and every yoga teacher checks effort and energy. The mentor here should do the same and write the answer down. Reading recent difficulty ratings is exactly how the mentor calibrates the next session into the flow zone (see DOMAIN_SESSION step 9 and profile.md's Calibration Log).

What a real mentor does NOT do is enforce a rigid schema around those signals. So the system does not:
- Refuse to record a session because the input doesn't match a schema
- Require a slug, enum, or pre-registered topic-id as a precondition for writing anything
- Block work because the topic isn't in the curriculum yet
- Coerce nuanced observations into typed fields with validation gates

The mentor asks the human question, writes the answer in prose (`Difficulty: 7/10 — flow zone, slightly under-challenged near the end`), and moves on. The data is collected; the schema is not enforced. If the system does enforce schemas at the writing gate, it is an LMS in mentor's clothing. We are building a mentor team, not an LMS.

## P8. One canonical layer per granularity. Higher layers are mentor-compressed from lower, never written independently.

- `sessions/<date>.md` is canonical at session granularity.
- `log.md` is the chronological index of session pages — one line per session, mentor-maintained.
- `done_topics.md` is the catalog at topic granularity — derived from session pages by the mentor's deliberate act of summarizing.
- `current_focus.md` is the mentor's working memory at week/phase granularity — derived from recent session pages and curriculum position.
- `curriculum.md` is the concept layer — evolves slowly, mentor edits when curriculum adapts.
- `archive/phase_<N>_<slug>.md`, `archive/season_<N>_<period>.md`, `archive/year_<YYYY>.md` are the boundary-time compression layers. Each is written once by the mentor at a natural protocol boundary (phase advance → DOMAIN_SESSION JOURNAL step; season end → SEASON_TRANSITION; year boundary → first WEEKLY_REVIEW of new year) and is **immutable thereafter** — corrections live as dated notes in the active `log.md`, not as rewrites of past archives. This pyramid is what keeps per-session read cost bounded as the system ages: PREPARE reads `log.md` only from the start of the current phase, plus the immediately previous phase archive for adjacency context; deeper archives are read on demand only.

Each layer has *one* writer (the mentor) and a clear derivation rule from the layer below. This rules out parallel-write caches; it permits deliberate mentor-summarization between layers. Two write targets for the same fact = drift by construction.

## P9. The mentor system is a mentor's notebook — not a wiki.

A human mentor working with a long-term student keeps a folder per student: a topics-covered list, a current-focus sheet, a stack of session journals, a curriculum sketch. Before each meeting they skim the relevant pages. During the meeting they coach. After the meeting they jot a session note and update the topics-covered list. Periodically they re-read the folder and notice drift. **That is exactly what this system is.** The files in `mentors/<domain>/` are coaching artifacts for an evolving relationship, not encyclopedia entries.

This matters because it tells us what NOT to build. A mentor's notebook is not a knowledge graph; pages don't need to cross-reference and compound. There is no ingest pipeline; the "input" is a conversation that doesn't persist. There is no library of entity pages; there is a focus sheet and a journal. The right operations are the ones a human mentor performs:

- **Prepare** (before a session): read the relevant folder pages — most importantly `done_topics.md` (so you don't reassign work, the P1 fix) and `current_focus.md` (so you remember where you left off).
- **Coach** (during): have the conversation. Push back when warranted. Calibrate.
- **Journal** (after): write the session page, update the topics-covered list, update the focus sheet, edit the curriculum if it adapted, sync.
- **Audit** (periodically, inside WEEKLY_REVIEW): re-read the folder for drift, contradictions, stale claims, missing entries, aged calibration flags.

What is **not** this system:

- Not a Karpathy-style LLM Wiki. That pattern — LLM ingests raw documents into a cross-referenced wiki of concept pages — fits `knowledge-store/`, which is a separate system with its own architecture. Mentors may *read* from `knowledge-store/wiki/`, but mentors do not maintain a wiki of their own.
- Not an LMS. No structured fields, no validators in the user-facing loop, no schemas on the page level.
- Not an ingestion pipeline. Sessions are conversations, not documents to be parsed.

This principle is downstream of P7 (the human-mentor metaphor is the test). It exists separately because the wrong framing has actively misled the architecture once already; naming the right framing protects against repeating that.

---

## When to re-examine these principles

- A core principle is genuinely failing in practice (not just inconvenient).
- A better pattern has been proven elsewhere and we want to adopt it.
- The system's purpose has shifted (e.g., from personal mentor to multi-user platform).

Patch the principles deliberately. Do not patch around them.
