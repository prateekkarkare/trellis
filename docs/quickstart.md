# Quickstart — Your first session in under 10 minutes

## 0. Prerequisites

- An LLM client. Any of: Claude Desktop, Claude Code, GitHub Copilot in VS Code, ChatGPT Projects, or anything that can read+write files in a folder.
- `git` and `bash` (you almost certainly have these).
- About 10 minutes of attention.

## 1. Clone the framework

```bash
git clone https://github.com/<you>/Trellis.git
cd Trellis
```

## 2. Run init

```bash
./scripts/init.sh
```

It will ask you a handful of questions:

- **Your name** — used in the profile and protocols.
- **Workspace name** — e.g. "Athena Notebook", "Mentor Team", whatever you'd call it.
- **Timezone** — IANA name like `America/Los_Angeles` or `Asia/Kolkata`.
- **Notebook directory** — where your personal content lives. Default: `../my-notebook`. Pick something *outside* the Trellis clone so you can pull framework updates without conflicts.
- **LLM client** — which client you're driving from. Determines which path-discovery strategy the protocols use.
- **Initial domains** — comma-separated. Don't try to enumerate everything; pick 3-5 areas you'll actually work on this season.
- **Season cadence** — defaults to 90-day seasons with weekly reviews on Sunday. Override if you have reason.

The script generates your notebook tree, writes a personalized `CONFIG.md`, copies the framework's protocol docs into `<notebook>/framework/`, and creates a folder per domain from the template.

## 3. Initialize the notebook as its own git repo

```bash
cd ../my-notebook    # or whichever path you chose
git init
git add -A
git commit -m "initial bootstrap from Trellis"
# Push to a PRIVATE remote — this folder will contain personal content.
```

## 4. Point your LLM client at the notebook

Pick the guide for your client:

- [Claude Desktop](client-setup/claude-desktop.md)
- [Claude Code](client-setup/claude-code.md)
- [GitHub Copilot (VS Code)](client-setup/github-copilot.md)
- [ChatGPT Projects](client-setup/chatgpt.md)

All four boil down to: the model needs to be able to read `framework/PROTOCOLS.md`, `framework/FIRST_PRINCIPLES.md`, and the contents of `mentors/`, and write back to `mentors/`.

## 5. Run your first session

In the LLM client, say something like:

> *"Let's do a session on writing."*  (replace `writing` with one of your initial domains)

The mentor should:

1. Discover the path to your notebook (per the strategy in `framework/PROTOCOLS.md` → "PATH DISCOVERY").
2. Read `mentors/writing/done_topics.md` first (P1 — never reassign work).
3. Read `current_focus.md`, `curriculum.md`, `log.md`, `intel.md`.
4. Read `profile.md` to know who you are.
5. Have the actual conversation.
6. At session end, write `mentors/writing/sessions/<date>.md`, append to `log.md`, append to `done_topics.md`, update `current_focus.md`.

If the model skipped any of those steps, paste this into the chat and try again:

> *"You're operating under the protocols in `framework/PROTOCOLS.md`. Run DOMAIN_SESSION. Use the path-discovery method in that file. Read done_topics.md before proposing anything."*

## 6. Run your first weekly review

After you've had a few sessions across a few domains, say:

> *"Weekly review."*

The coordinator will:

1. Gather signals (from your task tracker if you wired up a connector, from `mentors/*/log.md` and `mentors/*/sessions/` otherwise).
2. Pause and ask you to confirm the signal brief is accurate. **This is the first checkpoint.** Don't skip it; this is where the mentor finds out what really happened.
3. Spawn one mentor agent per Active/Seeding domain, in parallel, with the signal brief.
4. Synthesize their reports into one cross-domain plan.
5. Pause and present that plan for your approval. **Second checkpoint.**
6. Write outputs: update `current_focus.md` per domain, update `coordinator_state.md`, append to `cross_domain.md` if anything new emerged.

## 7. Iterate

The system gets dramatically better around week 3-4 because by then `profile.md` has real observations, `done_topics.md` has real entries, and the mentors have real calibration data. Don't judge it on the first session — judge it on the first month.

---

## What if something goes wrong?

- **The mentor isn't reading the right files.** Check `framework/PROTOCOLS.md` is in context and that the path-discovery section matches your client. See [docs/customization.md](customization.md) for the path discovery rules.
- **The mentor is too agreeable.** Bump `COMM_TONE` in `CONFIG.md` to 4 or 5. Also remind it: *"Run the critical-thinking pass from PROTOCOLS.md step 7 before giving me recommendations."*
- **The system feels heavy.** It is, the first time. Once `current_focus.md` and `done_topics.md` are populated, mentors read much less. Most steady-state sessions cost ~1500 tokens of context, not 15000.
- **Anything else.** Open an issue. The framework is the README of its own behavior; if the README is wrong, that's a bug.
