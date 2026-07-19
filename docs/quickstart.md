# Setup — from clone to your first session (Claude Cowork)

This is the **complete, no-assumptions** walkthrough. Every step is here. It targets **Claude Cowork** (the only client we support right now). Total time: ~10 minutes, most of it the conversation.

There are two ways to set up. **Path A (the wizard)** is the normal one. **Path B (manual)** is the same thing by hand, if you ever want it.

---

## What you need first

- **Claude Cowork access** — this is where your mentors live and do their work.
- **git** — to download the framework. (Check: run `git --version`.)
- **python3** — powers the click-through wizard. Preinstalled on macOS and most Linux. (Check: `python3 --version`.) If you don't have it, use Path B.
- A **terminal** — you run exactly one command in it. That's the only terminal step.

---

## Path A — the wizard (recommended)

### Step 1 — Download the framework

In a terminal:

```bash
git clone https://github.com/<you>/Trellis.git
cd Trellis
```

You're now inside the `Trellis` folder. This folder is the **framework** (the operating manual). Your personal notebook will be created *next to it*, not inside it.

### Step 2 — Run the one command

```bash
./scripts/start.sh
```

A wizard opens in your web browser. (If it doesn't auto-open, the terminal prints a `http://127.0.0.1:…` link — click it.) Leave the terminal open while you use the wizard.

### Step 3 — Click through the wizard

Five quick screens:

1. **Notebook name + location** — what to call your mentor team (e.g. "My Mentor Team"), and **where to create it** on your computer. The wizard pre-fills a sensible folder and shows a live *"Creates: …/your-notebook"* preview; change it if you want it somewhere else. Optionally your first name.
2. **Mentors** — type or tap the pursuits you want a mentor for (fitness, finances, a craft…). Add as many as you like; you can hire more later.
3. **Rhythm** — your *starting* settings: how much time you can give per day, which day you want your weekly review, and how long a season is. **These are not final** — your mentor confirms and adjusts them in the conversation. This is where time budget / review day / season length get set.
4. **Signals (optional)** — connect an input your mentors learn from (Todoist, calendar…). You can skip and wire these later.
5. **Create my team** — press it.

### Step 4 — What just happened (the wizard did this for you)

Behind the scenes the wizard created your **notebook folder** at the location you chose (default: right next to the `Trellis` folder, with a folder name derived from your notebook name) containing:

```
my-notebook/
├── CLAUDE.md                 # ★ THE ENTRY POINT — Claude reads this automatically.
│                            #   It says "you are the mentor team, run INTAKE" and
│                            #   carries your wizard choices (the "Setup brief").
├── CONFIG.md                 # your settings (name, rhythm, client)
├── profile.md               # empty — your mentor fills this in the conversation
├── framework/               # the operating manual the mentor reads (PROTOCOLS.md, …)
├── .claude/skills/          # WEEKLY_REVIEW + DOMAIN_SESSION (load verbatim on trigger)
├── mentors/
│   ├── MEMORY.md            # empty — fills as you correct your mentors (lessons·facts·asks)
│   ├── season_current.md
│   ├── <each mentor you picked>/   # one folder per mentor, marked "needs intake"
│   └── …
└── .trellis/                # machine state only (not read by the mentor)
```

**Why `CLAUDE.md` matters:** when you connect a folder, Claude doesn't read every file — it auto-loads a root `CLAUDE.md` as its instructions. That's how it knows it's your mentor team instead of a generic assistant. Your wizard choices are written *into* `CLAUDE.md` (a visible file), not hidden away — so there's nothing for Claude to “discover.”

You did **not** set any goals yet. That's intentional — goals come from the conversation, not a form.

### Step 5 — Connect the notebook folder to Claude Cowork

This is the one manual handoff. In Claude Cowork, **give Cowork access to your `my-notebook` folder** (the path is shown on the wizard's final screen) so Claude can read and write the files in it.

> *(Exact Cowork UI: attach/mount the folder to your Cowork project the same way you connect any working folder. If you already run a Trellis-style notebook in Cowork, connect this one the same way.)*

### Step 6 — Meet your mentors (the conversation)

In Cowork, type:

> **start my intake**

No copy-paste needed: when you connected the folder, Claude already loaded `CLAUDE.md`, which tells it to run **`PROTOCOL: INTAKE`** and carries your wizard choices. It runs:

- **Part A — gets to know you** (once): who you are, your real weekly time, and confirms the rhythm you set in the wizard. Writes `profile.md`.
- **Part B — one mentor at a time**: for each mentor you hired, that domain's expert runs its *own* first session — your goals there, your honest starting point, the domain-specific questions a real coach would ask, and it ends by doing **one real piece of work** with you, then asks you to confirm it got things right.

You talk; Claude writes every file. This is the conversation — it lives in Cowork, not the wizard.

> **If Claude makes a generic to-do list / dashboard instead** (its default “start” behavior), it didn't load `CLAUDE.md` — the folder probably isn't connected, or you're in a project that isn't pointed at it. Make sure the notebook folder is connected, then paste the wizard's **“Copy the kickoff message”** as a fallback — it explicitly tells Claude to read `CLAUDE.md` and run INTAKE.

### Step 7 — Confirm it worked

After intake, your notebook should have real content. In a terminal:

```bash
cd ../my-notebook
cat profile.md                 # should describe you (no <placeholders>)
ls mentors/*/sessions/         # should list your first session file(s)
```

Or, from the `Trellis` folder, run the structural check:

```bash
./scripts/validate.sh --notebook ../my-notebook
```

That's the whole setup. You now have a populated notebook and a first real win in your top domain.

---

## Path B — manual (no wizard)

Same result, by hand. Use this if you don't have `python3` or prefer the CLI.

```bash
git clone https://github.com/<you>/Trellis.git
cd Trellis

# Scaffold the notebook + your mentors in one non-interactive command.
# (No prompts. The rhythm flags are starting values your mentor confirms later.)
./scripts/init.sh \
  --name "Asha" \
  --domains "fitness,finances,music" \
  --review-day Sunday \
  --season-length 90 \
  --time-ceiling 180
```

Then:

1. Connect `../my-notebook` to Claude Cowork (Step 5 above).
2. In Cowork, say **"start my intake"** (Step 6 above).

To add a mentor later from the CLI: `./scripts/add-domain.sh <name> --notebook ../my-notebook`. (Or just say *"hire a `<name>` mentor"* in Cowork — easier.)

---

## After setup — the everyday commands

You run these by **talking to Claude in Cowork** (never by editing files yourself):

| You say… | What happens |
|---|---|
| `let's do a session on <domain>` | A normal coaching session in that domain. |
| `hire a <domain> mentor` | Adds a new mentor and runs its first conversation (INTAKE Part B). |
| `weekly review` | The coordinator reviews your week across all mentors and plans the next one. |
| `season review` | End-of-season retrospective + designs the next season. |

---

## Where your settings live (and how to change them)

Everything is in **`CONFIG.md`** at the top of your notebook — plain text, edit any time, or just tell your mentor *"change my weekly review to Saturday"* and it edits the file.

| Setting | Where it's set | Default |
|---|---|---|
| Weekly review day | Wizard "Rhythm" → confirmed at intake → `CONFIG.md` | Sunday |
| Weekly time budget (per-day ceiling, per-week floor) | Wizard "Rhythm" → confirmed at intake → `CONFIG.md` | 180 / 90 min |
| Season length | Wizard "Rhythm" → confirmed at intake → `CONFIG.md` + `season_current.md` | 90 days |
| Mentor refresh cadence | `CONFIG.md` (internal default; rarely changed) | every 4 weeks |
| Tone / format | Conversation (mentor learns your preference) → `CONFIG.md` | 3 / mixed |

The rule: **the wizard sets a starting value, the mentor confirms it with you, and `CONFIG.md` is the source of truth thereafter.**

---

## Make the notebook your own git repo (recommended)

Your notebook is personal data. Keep it in your own private repo:

```bash
cd ../my-notebook
git init
git add -A
git commit -m "initial setup from Trellis"
# then push to a PRIVATE remote of your own.
```

You can keep pulling framework updates into the `Trellis` clone without touching your notebook.

---

## Troubleshooting

- **The wizard didn't open a browser.** Look in the terminal for a `http://127.0.0.1:…` link and open it yourself.
- **"start my intake" did nothing.** Make sure the `my-notebook` folder is connected to Cowork (Step 5). Then paste the wizard's **kickoff message** and send.
- **Claude talked but didn't write files.** Say: *"You're running the protocols in `framework/PROTOCOLS.md`. Journal this — write the files."* Writing the files is the whole contract.
- **I want to start over.** Delete the `my-notebook` folder and re-run `./scripts/start.sh` (or `./scripts/init.sh --force`).
- **No python3.** Use **Path B**. The wizard's final screen also prints the exact `init.sh` command for your choices.
