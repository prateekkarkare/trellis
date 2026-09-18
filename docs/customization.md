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

Different LLM clients mount your notebook differently. The protocols define `[ROOT]` as the directory that contains `CLAUDE.md` and `mentors/`, with a `find … -name MEMORY.md -path '*/mentors/*'` fallback for sandboxed mounts (Cowork's `/sessions/<id>/mnt/…`).

If your client mounts files differently, edit the **PATH & DATE DISCOVERY** block near the top of `core/PROTOCOLS.md` (in your notebook's `framework/` copy) and at the top of both skills — leave the `date` line in place; change only the notebook-root discovery. For most clients the simplification is:

```
The user's notebook is at `<NOTEBOOK_ROOT>` (see CONFIG.md).
All file paths below are relative to that root.
```

That's literally enough for Claude Desktop Projects, ChatGPT Projects, and Copilot.

## 6. Critical-thinking discipline

The 3-step pass (signal triage / devil's advocate / historical pattern gate) is defined in `.claude/skills/weekly-review/mentor_prompt.md` step 7 (and inline in the domain-session skill, step 9). If you find the mentor isn't running it:

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

Each domain mentor has a persona: the `## Stance` section of `mentors/<domain>/current_focus.md` (Archetype / Reasons with / Never prescribes / Pushes back by). Edit it, or ask the mentor to, e.g.:

> *"Archetype: no-nonsense ex-physio. Reasons with: measurements and protocols, not platitudes. Never prescribes: volume without a recovery plan. Pushes back by: asking a follow-up question before accepting 'I didn't feel like it'."*

The mentor adopts the Stance at PREPARE in every session and every weekly review.

## 10. Migrating from this framework

The whole point of the prose-first design is that you should never feel locked in. If you outgrow Trellis:

- Your data is all markdown in git. Take it.
- The protocols are just instructions to the LLM. Strip them out and you have a perfectly valid Obsidian / Logseq / plain folder of notes.
- The connectors are just configuration. They work with any other system that reads YAML.

Migration plan: copy `mentors/` (it holds `profile.md` and `MEMORY.md`) and `CONFIG.md` to the new system. Delete `framework/`. Done.
