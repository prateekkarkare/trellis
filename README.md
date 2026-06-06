# Trellis

> *A trellis holds a plant up. It doesn't tell it where to grow.*
> A markdown-native framework for running your own team of expert AI mentors across the domains of your life.

**✦ [See the visual overview →](https://prateekkarkare.github.io/trellis/)**

Trellis turns any capable LLM (Claude, ChatGPT, Copilot, local models) into a **disciplined personal mentor team** — one specialist per domain (fitness, finances, a craft, a business, parenting, anything), coordinated by a weekly review, journaling everything to plain markdown that you own forever.

---

## Why this exists

Most "AI assistant" setups die after a few weeks because:

1. **They forget.** Every conversation starts from zero.
2. **They cheerlead.** The model agrees with whatever you said last.
3. **They sprawl.** No consistent place to find what was decided, what's next, what's behind.
4. **They lock you in.** Your context lives inside a vendor's UI.

Trellis fixes all four with a single idea: **the mentor keeps the notebook, not the user.** The LLM reads the relevant pages before every session, has the conversation, writes the journal entry, updates the catalog of completed topics, and edits the focus sheet. You write by talking. The system runs on plain text files in a git repo you own. It outlives any specific tool.

---

## What you get

```
Trellis/
├── core/                   # The protocol layer — operating manual for the mentor team
│   ├── FIRST_PRINCIPLES.md     # The constitution. 9 principles. Read first.
│   ├── PROTOCOLS.md            # INTAKE, DOMAIN_SESSION, WEEKLY_REVIEW, etc.
│   ├── WIKI_BRIDGE.md          # How mentors interact with an external knowledge base
│   └── *.template              # Parameterized starter docs (profile, season, coordinator)
├── onboarding/              # The visual setup wizard (single-file HTML)
├── templates/domain/       # Scaffold for a new domain mentor — copied per domain
├── examples/example_domain/    # One fully-populated worked example to learn from
├── connectors/             # Adapter stubs: Todoist, Calendar, Slack (you wire them up)
├── scripts/                # start.sh (the one command), init.sh (scaffold), add-domain.sh, validate.sh
└── docs/                   # Quickstart, concept guide, client-specific setup notes
```

Run `./scripts/start.sh` and a visual wizard walks you through setup; your **personal notebook** is created alongside the framework. You commit it to your own private repo, and keep pulling framework updates upstream without your personal content leaking.

---

## Quickstart (5 minutes)

```bash
# 1. Clone the framework
git clone https://github.com/<you>/Trellis.git
cd Trellis

# 2. Run the wizard — the one command. A visual onboarding opens in your browser.
./scripts/start.sh
#  → name your notebook → pick your mentors → set your rhythm → (optional) signals
#  → press "Create my team": it scaffolds your notebook + a folder per mentor
```

Then, in **Claude Cowork**:

```text
3. Connect your new  ../my-notebook  folder to Cowork (one time).
4. Say:  start my intake
     → Each mentor runs its own first conversation: gets to know you, sets that
       domain's goals with you, and does one real piece of work. Makes it yours.
5. Day to day:  "let's do a session on <domain>"  ·  "weekly review"  ·  "hire a <domain> mentor"
```

Every step, no assumptions: **[docs/quickstart.md](docs/quickstart.md)**. (Prefer the CLI to the wizard? `./scripts/init.sh` scaffolds the notebook non-interactively.)

---

## How it works (one paragraph)

You onboard through a **visual wizard** (`./scripts/start.sh`) — name your notebook, pick your mentors, set your rhythm; it scaffolds your notebook and a folder per mentor. You connect that folder to **Claude Cowork** and say *"start my intake."* Then comes the one-time **intake**: each mentor runs its own first conversation — gets to know you, asks the questions an expert in *that* domain would, co-designs the goals, and does a first piece of real work — so day one delivers value instead of a folder of empty templates. After that, each domain (fitness, music, a side project, parenting) gets a folder of plain markdown files: a curriculum, a catalog of done topics, a focus sheet, a session journal, an optional intel page. The LLM acting as that domain's mentor reads these before every session — most importantly the **done topics** so it never reassigns finished work. The mentor coaches the conversation, then writes a session page, updates the catalog, edits the focus sheet, and trims the log. A **coordinator** runs a weekly review across all domains: pulls signals from your task tracker if connected, spawns one mentor agent per active domain in parallel, synthesizes their reports, pauses for your input twice (signal check, plan check), then writes the next week's plan. A **season** is a 90-day arc with explicit exit criteria — at season end, archives roll up, and you design the next one.

The full architecture: [core/FIRST_PRINCIPLES.md](core/FIRST_PRINCIPLES.md). The full operating manual: [core/PROTOCOLS.md](core/PROTOCOLS.md).

---

## Design principles (the short version)

1. **Markdown prose is the source of truth.** Everything else is derived and disposable.
2. **The user writes by talking. The mentor writes the files.** No forms, no CLIs in the loop.
3. **One canonical layer per granularity.** Session → log → done-topics → focus → curriculum → archives. Higher layers are mentor-compressed from lower; never parallel-written.
4. **Critical thinking is built in.** Every mentor runs a 3-step pass — signal triage, devil's advocate, historical pattern gate — before recommending anything. Mentors push back. They are not yes-men.
5. **The human-mentor metaphor is the test.** Before adding any feature, ask: would a real human mentor demand this of their student? If no, don't build it.

Full statement: [core/FIRST_PRINCIPLES.md](core/FIRST_PRINCIPLES.md)

---

## Runs on Claude Cowork

Right now Trellis is set up and supported on **Claude Cowork** — that's the one path we document end to end, so it's reliable. Full step-by-step: **[docs/quickstart.md](docs/quickstart.md)**.

Under the hood the framework is just markdown and plain protocols — nothing is Claude-specific by design, so other file-reading assistants can run it too. Notes for other clients live in [docs/client-setup/](docs/client-setup/) but aren't first-class yet. We're keeping the supported surface small on purpose until the Cowork flow is rock-solid.

---

## Connectors

Optional adapters that feed external signals into the weekly review. Stubs and the wiring pattern are in [connectors/](connectors/). The framework works fine without any of them — connectors enrich the signal layer, they're not load-bearing.

Common ones:
- **Todoist** — primary task-completion signal for the weekly review
- **Calendar** — locked external commitments, energy-pattern detection
- **Slack** — work-context signals
- Anything else exposed via MCP, an API, or a flat file dump

---

## What this is NOT

- Not a knowledge wiki. (The mentor system is a notebook; a separate wiki/RAG layer is mentioned in [core/WIKI_BRIDGE.md](core/WIKI_BRIDGE.md) but optional.)
- Not an LMS. No structured fields, no schemas, no validators in the user-facing loop.
- Not a productivity tracker. It doesn't tell you what to do today; it tells you what the next *right* thing is given everything it knows about you.
- Not vendor-locked. Your data is markdown in git. Take it anywhere.

---

## License

[MIT](LICENSE). Use it, fork it, sell it, replace every word — go.

---

## Inspiration & credits

- The **mentor's-notebook** framing comes from how good human teachers actually keep records of their students over years.
- The **first-principles discipline** echoes Karpathy's *"prose is the durable substrate"* observation.
- The **devil's advocate / signal triage** discipline is borrowed from coaching practice and adversarial collaboration in research.

If you build something on top, open a PR or just send a note. This is meant to be a substrate, not a product.
