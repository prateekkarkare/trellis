# Customization

Things you'll probably want to tune. Listed roughly in order of how often people change them.

## 1. Communication tone

`CONFIG.md` → `COMM_TONE` (1-5).

- **1-2**: gentle, encouraging, soft on pushback. Good for early weeks while you're building trust with the system.
- **3**: default. Honest, direct, will push back when needed but not gratuitously.
- **4-5**: ruthless. The mentor will use language like *"you've skipped this 4 weeks running with no comment — this is avoidance, not busyness"*. Recommend bumping to 4 only once you trust the system; otherwise the bluntness will feel arbitrary.

## 2. Adding a domain

```bash
./scripts/add-domain.sh <slug> --notebook /path/to/your/notebook
```

Then open `mentors/season_current.md` and add a row for the new domain with its state (Active / Seeding / Silent) and an exit criterion.

## 3. Retiring a domain

Set its state to Silent in `mentors/season_current.md`. Don't delete the folder — its history is valuable. Silent domains are skipped by the coordinator entirely.

If you're sure you'll never return: move the folder to `mentors/_retired/<slug>/`. The protocols ignore `_*` folders.

## 4. Changing season cadence

`CONFIG.md` → `SEASON_LENGTH_DAYS`. Default 90.

Some domains do better on different cadences (a multi-year reading goal, a 30-day fitness cut). The framework only supports one season length system-wide for now — if you need per-domain seasons, the cleanest workaround is to phrase shorter goals as exit criteria within the standard season.

## 5. Path discovery

Different LLM clients mount your notebook differently. The current path-discovery section in `core/PROTOCOLS.md` is written for clients that expose a sandboxed filesystem (Claude Code with `/sessions/<id>/mnt/`-style mounts).

If your client mounts files differently, edit the **PATH DISCOVERY** section near the top of `core/PROTOCOLS.md` (in your notebook's `framework/` copy). For most clients the simplification is:

```
The user's notebook is at `<NOTEBOOK_ROOT>` (see CONFIG.md).
All file paths below are relative to that root.
```

That's literally enough for Claude Desktop Projects, ChatGPT Projects, and Copilot.

## 6. Critical-thinking discipline

The 3-step pass (signal triage / devil's advocate / historical pattern gate) is defined in `core/PROTOCOLS.md` → `WEEKLY_REVIEW` Phase 2 step 7 and referenced from a few other places. If you find the mentor isn't running it:

- Bump `COMM_TONE`.
- At the start of any session, paste: *"Before giving recommendations, run the critical-thinking pass from PROTOCOLS.md."*
- Consider using a model with stronger reasoning for the coordinator role (e.g. a frontier model for weekly reviews; a faster model is fine for individual domain sessions).

## 7. Splitting the model layer

The protocols don't enforce one model. A common split:

- **Coordinator** (runs WEEKLY_REVIEW, MENTOR_REFRESH) — a fast, cheap, good-at-orchestration model is fine. Sonnet / GPT-4o-mini / Gemini Flash class.
- **Domain mentors** (run DOMAIN_SESSION) — use the strongest reasoning model you have access to. This is where critical-thinking pays for itself. Opus / Sonnet-thinking / o1 / Gemini Pro thinking class.

If you only have one model, use it everywhere. The system was designed against a single capable model.

## 8. The wiki layer (optional)

`core/WIKI_BRIDGE.md` describes how mentors interact with an external knowledge base if you have one (e.g. an Obsidian vault, a Karpathy-style LLM-built wiki, or any markdown collection). The framework works fine without one — leave WIKI_BRIDGE.md in place; mentors will see *"no wiki configured"* and proceed.

If you set one up: add its path to `CONFIG.md` (custom variable, e.g. `WIKI_PATH`) and edit `WIKI_BRIDGE.md` to use it.

## 9. Per-mentor system prompts

You can give each domain mentor its own micro-personality / style by editing the top of `mentors/<domain>/intel.md` with a paragraph like:

> *"The fitness mentor is a no-nonsense ex-physio. Speaks in measurements and protocols, not platitudes. Will not accept 'I didn't feel like it' as a reason without a follow-up question."*

The mentor will read this at PREPARE and adopt the framing.

## 10. Migrating from this framework

The whole point of the prose-first design is that you should never feel locked in. If you outgrow Trellis:

- Your data is all markdown in git. Take it.
- The protocols are just instructions to the LLM. Strip them out and you have a perfectly valid Obsidian / Logseq / plain folder of notes.
- The connectors are just configuration. They work with any other system that reads YAML.

Migration plan: copy `mentors/`, `profile.md`, and `CONFIG.md` to the new system. Delete `framework/`. Done.
