# Wiki Bridge — How Mentors Use the Knowledge Wiki

The mentor system reads from and writes to the wiki at `../knowledge-store/wiki/`. The wiki does not depend on this mentor system.

## When to Read the Wiki

At the start of any mentor session, after loading profile.md and curriculum.md:
1. Read `../knowledge-store/wiki/index.md`
2. Find pages relevant to today's session topic
3. Read those pages — this gives you the compiled knowledge {{USER_NAME}} already has, so you don't re-explain what he knows and you build on it correctly

## When to Write to the Wiki

At the END of every session:
1. Extract 1–3 distinct learnings or new claims from the session
2. Update or create relevant concept/entity/synthesis pages in `../knowledge-store/wiki/`
3. Append to `../knowledge-store/wiki/log.md`
4. Update `../knowledge-store/wiki/index.md` if new pages were created

## When the Wiki Should Update the Curriculum

The wiki feeds back into mentor quality through curriculum updates. Two triggers:

**On ingest**: When a new source is ingested, check if it contains a better resource, revised progression, or gap that the curriculum hasn't addressed. If yes — update `[domain]/curriculum.md` and mark the change with `> ✏️ Updated from ingest: [source] [date]`.

**On Sunday lint**: Review whether accumulated wiki knowledge (synthesis pages, high-confidence concept pages) has made any curriculum section obsolete or incomplete. Surface explicitly, update if warranted.

This is the loop that makes mentors grow — not just better-informed sessions, but structurally improved plans.

## What the Wiki Is NOT

- It is not a session log. That lives in `[domain]/log.md` (chronological, stays here).
- It is not a curriculum. That lives in `[domain]/curriculum.md` (stays here).
- The wiki is the distilled knowledge that emerges FROM sessions and sources.

## Isolation Guarantee

If the entire `mentors/` directory is deleted, `../knowledge-store/wiki/` continues to function independently. Never write mentor-system-specific logic into wiki pages.
