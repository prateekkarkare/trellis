#!/usr/bin/env bash
# ============================================================================
# Trellis — Notebook Scaffolder (init.sh)
# ============================================================================
# Creates the bare notebook scaffold so the onboarding INTAKE conversation can
# run. NON-INTERACTIVE by design: it asks nothing. Everything comes from flags
# (the wizard passes them) or sane defaults. The values it writes are *starting*
# values your mentor confirms with you during intake — the script never holds a
# conversation. Idempotent: safe to re-run. Files are NOT overwritten unless
# --force.
#
# Usage:
#   ./scripts/init.sh                              # all defaults, no domains
#   ./scripts/init.sh --name "Asha"               # override name (default: whoami)
#   ./scripts/init.sh --notebook ../my-nb         # target dir (default: ../my-notebook)
#   ./scripts/init.sh --domains "fitness,music"   # optional: pre-create folders
#   ./scripts/init.sh --season-length 90          # rhythm: season length in days
#   ./scripts/init.sh --review-day Sunday         # rhythm: weekly review day
#   ./scripts/init.sh --time-ceiling 180          # rhythm: minutes/weekday ceiling
#   ./scripts/init.sh --force                     # overwrite existing files
#   ./scripts/init.sh --config answers.env        # load overrides (automation)
# ============================================================================

set -euo pipefail

# --- locate framework root --------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$FRAMEWORK_ROOT"

# --- args -------------------------------------------------------------------
FORCE=0
CONFIG_FILE=""
CLI_NAME=""; CLI_NOTEBOOK=""; CLI_CLIENT=""; CLI_DOMAINS=""
CLI_SEASON_LEN=""; CLI_REVIEW_DAY=""; CLI_TIME_FLOOR=""; CLI_TIME_CEILING=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --name) CLI_NAME="$2"; shift 2 ;;
    --notebook) CLI_NOTEBOOK="$2"; shift 2 ;;
    --client) CLI_CLIENT="$2"; shift 2 ;;
    --domains) CLI_DOMAINS="$2"; shift 2 ;;
    --season-length) CLI_SEASON_LEN="$2"; shift 2 ;;
    --review-day) CLI_REVIEW_DAY="$2"; shift 2 ;;
    --time-floor) CLI_TIME_FLOOR="$2"; shift 2 ;;
    --time-ceiling) CLI_TIME_CEILING="$2"; shift 2 ;;
    --config) CONFIG_FILE="$2"; shift 2 ;;
    -h|--help)
      cat <<'USAGE'
Trellis init.sh — scaffold a notebook (non-interactive; asks nothing)

  ./scripts/init.sh                              all defaults, no domains
  ./scripts/init.sh --name "Asha"               set the name (default: whoami)
  ./scripts/init.sh --notebook ../my-nb         target dir (default: ../my-notebook)
  ./scripts/init.sh --domains "a,b"             optional: pre-create domain folders
  ./scripts/init.sh --season-length 90          rhythm: season length (days)
  ./scripts/init.sh --review-day Sunday         rhythm: weekly review day
  ./scripts/init.sh --time-ceiling 180          rhythm: minutes/weekday ceiling
  ./scripts/init.sh --force                     overwrite existing files
  ./scripts/init.sh --config answers.env        load overrides (automation)

The rhythm values are STARTING values — your mentor confirms them with you in
the intake conversation. The wizard (scripts/start.sh) passes them for you.
USAGE
      exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

# --- helpers ----------------------------------------------------------------
c_bold=$'\033[1m'; c_dim=$'\033[2m'; c_green=$'\033[32m'; c_yellow=$'\033[33m'; c_red=$'\033[31m'; c_reset=$'\033[0m'
say()  { printf "%s\n" "$*"; }
ok()   { printf "%s✓%s %s\n" "$c_green" "$c_reset" "$*"; }
warn() { printf "%s⚠%s %s\n" "$c_yellow" "$c_reset" "$*"; }
err()  { printf "%s✗%s %s\n" "$c_red" "$c_reset" "$*" >&2; }

# --- banner -----------------------------------------------------------------
cat <<'BANNER'

  ┌─────────────────────────────────────────────────────────┐
  │   Trellis — your mentor's-notebook framework            │
  │   Initializing your personal notebook...                │
  └─────────────────────────────────────────────────────────┘

BANNER

# --- load config file if provided ------------------------------------------
if [[ -n "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
  ok "loaded answers from $CONFIG_FILE"
fi

# --- resolve parameters (non-interactive; CLI flag > env > default) ---------
USER_NAME="${USER_NAME:-${CLI_NAME:-$(whoami)}}"
# NB: keep the apostrophe out of any ${VAR:-default} — bash 3.2 mis-parses a
# single quote inside ${:-...} as a quote opener. Set the default separately.
WORKSPACE_NAME="${WORKSPACE_NAME:-}"
[[ -n "$WORKSPACE_NAME" ]] || WORKSPACE_NAME="$USER_NAME's Notebook"
TIMEZONE="${TIMEZONE:-$(date +%Z)}"
NOTEBOOK_ROOT="${NOTEBOOK_ROOT:-${CLI_NOTEBOOK:-../my-notebook}}"
# Resolve to an absolute path WITHOUT requiring the parent to pre-exist (the
# wizard may target a brand-new nested folder). Make absolute, create it, then
# canonicalize. (The old dirname-based form produced "/<basename>" when the
# parent didn't exist yet.)
case "$NOTEBOOK_ROOT" in
  /*) : ;;                                    # already absolute
  *)  NOTEBOOK_ROOT="$PWD/$NOTEBOOK_ROOT" ;;  # relative → anchor at CWD (framework root)
esac
mkdir -p "$NOTEBOOK_ROOT"
NOTEBOOK_ROOT="$(cd "$NOTEBOOK_ROOT" && pwd)"
CLIENT="${CLIENT:-${CLI_CLIENT:-claude-cowork}}"

# Domains are OPTIONAL. Default: none — mentors are "hired" during the intake
# conversation, the same way you'd hire a coach. Pass --domains to pre-create.
DOMAINS_RAW="${DOMAINS_RAW:-${CLI_DOMAINS:-}}"
SLUG_DOMAINS=()
if [[ -n "${DOMAINS_RAW// /}" ]]; then
  IFS=',' read -r -a DOMAINS <<< "$DOMAINS_RAW"
  for d in "${DOMAINS[@]}"; do
    slug="$(echo "$d" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/[[:space:]]\+/_/g')"
    [[ -n "$slug" ]] && SLUG_DOMAINS+=("$slug")
  done
fi

# Rhythm = STARTING values only. The wizard passes these via flags; bare init
# uses sane defaults. The script never *asks* — the intake conversation confirms
# them with the user. ("Both: wizard sets, mentor confirms.")
SEASON_NUM="${SEASON_NUM:-1}"
SEASON_START="${SEASON_START:-$(date +%Y-%m-%d)}"
SEASON_LENGTH_DAYS="${SEASON_LENGTH_DAYS:-${CLI_SEASON_LEN:-90}}"
if date -v+1d -j -f '%Y-%m-%d' "$SEASON_START" '+%Y-%m-%d' >/dev/null 2>&1; then
  SEASON_END="${SEASON_END:-$(date -v+${SEASON_LENGTH_DAYS}d -j -f '%Y-%m-%d' "$SEASON_START" '+%Y-%m-%d')}"
else
  SEASON_END="${SEASON_END:-$(date -d "$SEASON_START + $SEASON_LENGTH_DAYS days" '+%Y-%m-%d')}"
fi
WEEKLY_REVIEW_DAY="${WEEKLY_REVIEW_DAY:-${CLI_REVIEW_DAY:-Sunday}}"
MENTOR_REFRESH_WEEKS="${MENTOR_REFRESH_WEEKS:-4}"
TIME_FLOOR_PER_DOMAIN="${TIME_FLOOR_PER_DOMAIN:-${CLI_TIME_FLOOR:-90}}"
TIME_CEILING_PER_DAY="${TIME_CEILING_PER_DAY:-${CLI_TIME_CEILING:-180}}"
COMM_TONE="${COMM_TONE:-3}"
COMM_FORMAT="${COMM_FORMAT:-mixed}"
PROTOCOL_MODE="${PROTOCOL_MODE:-checkpoints}"

# --- summary (no confirmation — non-interactive) ---------------------------
say ""
say "${c_bold}Scaffolding${c_reset}"
say "  User:           $USER_NAME"
say "  Notebook root:  $NOTEBOOK_ROOT"
say "  Client:         $CLIENT"
if (( ${#SLUG_DOMAINS[@]} )); then
  say "  Pre-created:    ${SLUG_DOMAINS[*]}  ${c_dim}(each still needs its mentor intake)${c_reset}"
else
  say "  Mentors:        ${c_dim}none yet — you'll hire them in your intake conversation${c_reset}"
fi
say ""

# --- create notebook tree ---------------------------------------------------
mkdir -p "$NOTEBOOK_ROOT"/{mentors,coordinator_history}
mkdir -p "$NOTEBOOK_ROOT"/.trellis

# --- substitution helper ----------------------------------------------------
# Build multi-line replacement blocks in temp files (avoids BSD awk's
# "newline in string" error when passing multi-line vars via -v).
SUBST_TMP="$(mktemp -d -t trellis-subst.XXXXXX)"
trap 'rm -rf "$SUBST_TMP"' EXIT
{
  if (( ${#SLUG_DOMAINS[@]} )); then
    for d in "${SLUG_DOMAINS[@]}"; do
      printf -- "- %s (needs intake)\n" "$d"
    done
  else
    printf -- "%s\n" "- (none yet — your mentors are created during the intake conversation)"
  fi
} > "$SUBST_TMP/domain_list.txt"
printf -- "- (none configured — see connectors/connectors.example.yml to wire one up)\n" \
  > "$SUBST_TMP/connector_list.txt"

substitute() {
  # substitute <src> <dest>
  local src="$1" dest="$2"
  if [[ -f "$dest" && $FORCE -eq 0 ]]; then
    warn "exists, skipping (use --force): ${dest#$NOTEBOOK_ROOT/}"
    return
  fi
  # Phase 1: scalar substitutions via sed.
  sed \
    -e "s|{{USER_NAME}}|$USER_NAME|g" \
    -e "s|{{WORKSPACE_NAME}}|$WORKSPACE_NAME|g" \
    -e "s|{{TIMEZONE}}|$TIMEZONE|g" \
    -e "s|{{NOTEBOOK_ROOT}}|$NOTEBOOK_ROOT|g" \
    -e "s|{{CLIENT}}|$CLIENT|g" \
    -e "s|{{SEASON_NUM}}|$SEASON_NUM|g" \
    -e "s|{{SEASON_START}}|$SEASON_START|g" \
    -e "s|{{SEASON_END}}|$SEASON_END|g" \
    -e "s|{{SEASON_LENGTH_DAYS}}|$SEASON_LENGTH_DAYS|g" \
    -e "s|{{WEEKLY_REVIEW_DAY}}|$WEEKLY_REVIEW_DAY|g" \
    -e "s|{{MENTOR_REFRESH_WEEKS}}|$MENTOR_REFRESH_WEEKS|g" \
    -e "s|{{TIME_FLOOR_PER_DOMAIN}}|$TIME_FLOOR_PER_DOMAIN|g" \
    -e "s|{{TIME_CEILING_PER_DAY}}|$TIME_CEILING_PER_DAY|g" \
    -e "s|{{COMM_TONE}}|$COMM_TONE|g" \
    -e "s|{{COMM_FORMAT}}|$COMM_FORMAT|g" \
    -e "s|{{PROTOCOL_MODE}}|$PROTOCOL_MODE|g" \
    "$src" > "$dest.tmp"

  # Phase 2: multi-line block substitutions via awk + getline from temp files.
  awk -v dl_file="$SUBST_TMP/domain_list.txt" -v cl_file="$SUBST_TMP/connector_list.txt" '
    /\{\{DOMAIN_LIST\}\}/    { while ((getline line < dl_file) > 0) print line; close(dl_file); next }
    /\{\{CONNECTOR_LIST\}\}/ { while ((getline line < cl_file) > 0) print line; close(cl_file); next }
    { print }
  ' "$dest.tmp" > "$dest"
  rm -f "$dest.tmp"
  ok "wrote ${dest#$NOTEBOOK_ROOT/}"
}

# --- framework docs: personalized copies (refreshed on every run) -----------
# These are the mentor's operating manual. Substitute the scalar tokens so the
# copy the mentor actually reads names the real user/workspace instead of
# {{PLACEHOLDERS}}. Always overwritten (unlike notebook content) so re-running
# init.sh after a framework update refreshes them.
mkdir -p "$NOTEBOOK_ROOT/framework"
for f in FIRST_PRINCIPLES.md PROTOCOLS.md WIKI_BRIDGE.md; do
  sed \
    -e "s|{{USER_NAME}}|$USER_NAME|g" \
    -e "s|{{WORKSPACE_NAME}}|$WORKSPACE_NAME|g" \
    -e "s|{{TIMEZONE}}|$TIMEZONE|g" \
    -e "s|{{NOTEBOOK_ROOT}}|$NOTEBOOK_ROOT|g" \
    -e "s|{{CLIENT}}|$CLIENT|g" \
    "$FRAMEWORK_ROOT/core/$f" > "$NOTEBOOK_ROOT/framework/$f"
  ok "wrote framework/$f"
done

# --- personalized top-level files -----------------------------------------
substitute "$FRAMEWORK_ROOT/core/CONFIG.md.template"            "$NOTEBOOK_ROOT/CONFIG.md"
substitute "$FRAMEWORK_ROOT/core/profile.md.template"           "$NOTEBOOK_ROOT/profile.md"
substitute "$FRAMEWORK_ROOT/core/season_current.md.template"    "$NOTEBOOK_ROOT/mentors/season_current.md"
substitute "$FRAMEWORK_ROOT/core/coordinator_state.md.template" "$NOTEBOOK_ROOT/mentors/coordinator_state.md"
substitute "$FRAMEWORK_ROOT/core/cross_domain.md.template"      "$NOTEBOOK_ROOT/mentors/cross_domain.md"

# --- create each domain from template (only if --domains was passed) -------
if (( ${#SLUG_DOMAINS[@]} )); then
  for d in "${SLUG_DOMAINS[@]}"; do
    domdir="$NOTEBOOK_ROOT/mentors/$d"
    if [[ -d "$domdir" && $FORCE -eq 0 ]]; then
      warn "exists, skipping (use --force): mentors/$d/"
      continue
    fi
    mkdir -p "$domdir/sessions" "$domdir/archive"
    for f in README.md current_focus.md done_topics.md intel.md curriculum.md log.md; do
      sed -e "s|<domain>|$d|g" -e "s|{{USER_NAME}}|$USER_NAME|g" \
          "$FRAMEWORK_ROOT/templates/domain/$f" > "$domdir/$f"
    done
    touch "$domdir/sessions/.gitkeep" "$domdir/archive/.gitkeep"
    ok "created mentors/$d/ (needs intake)"
  done
fi

# --- write user notebook README -------------------------------------------
cat > "$NOTEBOOK_ROOT/README.md" <<EOF
# $WORKSPACE_NAME

A personal mentor's-notebook built on [Trellis](https://github.com/your/Trellis).

## Files

- \`CLAUDE.md\` — **the entry point.** Claude reads this automatically when you connect the folder; it tells the mentor team what to do. Start here.
- \`CONFIG.md\` — your personalized parameters (edit any time)
- \`profile.md\` — behavioral profile, filled in by mentors over time
- \`mentors/\` — one folder per domain
- \`mentors/season_current.md\` — what's Active / Seeding / Silent this season
- \`mentors/coordinator_state.md\` — the coordinator's working memory
- \`mentors/cross_domain.md\` — bridges between domains
- \`framework/\` — copies of the protocol docs (replace by re-running init.sh after a framework update)

## Common commands

\`\`\`bash
# Talk to your mentor (in your LLM client):
"Let's do my intake"               # <- start here, once. Hires your mentors + sets you up.
"Hire a <domain> mentor"           # add a mentor any time (runs its own intake)
"Let's do a session on <domain>"   # a normal working session
"Weekly review"
"Season review"

# Prefer the command line to pre-create a mentor folder? (optional — the intake
# conversation does this for you):
cd $(realpath --relative-to="$NOTEBOOK_ROOT" "$FRAMEWORK_ROOT" 2>/dev/null || echo "<Trellis>")
./scripts/add-domain.sh <new_domain_slug> --notebook "$NOTEBOOK_ROOT"
\`\`\`

## Next steps

1. **Connect this folder to Claude Cowork.** Claude automatically reads \`CLAUDE.md\` here — that's the entry point that tells it it's your mentor team. You don't paste any system prompt.
2. **Run your intake — say: _"start my intake"_.** This first conversation is the most important step. Your mentor gets to know you, helps you **hire the mentors you want** (fitness, finances, a craft, whatever), sets each one's goals *with you*, and ends by doing one real piece of work. It's what turns this empty scaffold into *your* system. **You talk; the mentor writes the files** — don't hand-edit them yourself (FIRST_PRINCIPLES P2/P3).
3. After intake, work a domain (_"let's do a session on <domain>"_), hire more mentors any time (_"hire a <domain> mentor"_), and run your first _"weekly review"_ on the day you set at intake (Sunday by default).

## What the first few weeks feel like

Be patient through the cold start — it's by design, not a defect:

- **Week 1:** thin. The mentor only knows what you told it at intake. Advice is competent but not yet tailored.
- **Weeks 2–3:** it starts noticing your patterns — when you actually do the work, what you skip, what's miscalibrated.
- **Week 4+:** it gets good. \`profile.md\` fills with things you never said out loud, \`done_topics.md\` stops repeating work, and the weekly review catches what you didn't.

Judge the system at week 4, not session 1.

## How to tell it's actually working

The mentor writes files — that's the whole contract. After intake and after each session, confirm it did:

\`\`\`bash
# Did intake populate your profile? (should show real content, no <placeholders>)
cat profile.md

# Did the last session get journalled?
ls mentors/*/sessions/

# Structural health check any time (run from the Trellis framework folder):
./scripts/validate.sh --notebook "$NOTEBOOK_ROOT"
\`\`\`

If the mentor talked but wrote nothing, it skipped its job — tell it:
_"You're running the protocols in framework/PROTOCOLS.md. Journal this session — write the files."_

## Git

This notebook is your personal data. We strongly recommend you:

\`\`\`bash
cd "$NOTEBOOK_ROOT"
git init
git add -A
git commit -m "initial bootstrap from Trellis"
# Then push to a PRIVATE remote of your own.
\`\`\`
EOF
ok "wrote README.md"

# --- write CLAUDE.md: THE entry point the agent reads automatically --------
# Claude (Cowork/Projects/Code) auto-loads a root CLAUDE.md as its instructions.
# Without this, Claude has no idea it's a mentor team and falls back to a
# generic assistant. This file points it at the protocols and the setup brief.
# The SETUP_BRIEF markers are rewritten by the wizard with the user's choices.
cat > "$NOTEBOOK_ROOT/CLAUDE.md" <<EOF
# $WORKSPACE_NAME — start here (you are the mentor team)

You are **$USER_NAME's mentor team**, running the **Trellis** framework. This folder is the
notebook. Claude loads this file automatically when the folder is connected — treat it as your
standing instructions.

## Do this on the very first message

If the user says "start my intake" / "set me up", **or** this is clearly a fresh notebook
(\`profile.md\` still has \`<placeholder>\` text, or a **Setup brief** appears at the bottom of
this file):

1. Read \`framework/PROTOCOLS.md\` and run **PROTOCOL: INTAKE**.
2. Do **not** create a generic to-do list, TASKS.md, or dashboard. This is a mentor system,
   not a task tracker. Run the intake *conversation* — you ask, the user talks, you write the files.

## Every interaction

1. Read \`framework/PROTOCOLS.md\` (your operating manual) and \`CONFIG.md\` (settings).
2. Pick the protocol from what the user says:

   | The user says… | Run |
   |---|---|
   | "start my intake" / "set me up" | INTAKE (first run) |
   | "hire a \<domain\> mentor" | INTAKE — Part B for the new mentor |
   | "let's do a session on \<domain\>" | DOMAIN_SESSION |
   | "weekly review" | WEEKLY_REVIEW |
   | "season review" | SEASON_TRANSITION |

3. Run it exactly as written. Honor every checkpoint (pause and ask). You are not a yes-man —
   run the critical-thinking pass.
4. **At the end, write the files.** You keep the notebook, not the user (FIRST_PRINCIPLES P2/P3).

## Where things live (all inside THIS folder — never read or write outside it)

- \`framework/PROTOCOLS.md\` — the operating manual (every protocol, step by step)
- \`framework/FIRST_PRINCIPLES.md\` — the constitution (P1–P9)
- \`CONFIG.md\` — settings (name, rhythm, client)
- \`profile.md\` — who the user is (you fill this in during intake)
- \`mentors/<domain>/\` — one folder per mentor; read \`done_topics.md\` before proposing work
- \`mentors/season_current.md\` — what's active this season

<!-- SETUP_BRIEF_START -->
## Setup brief

(No setup brief — this notebook was created from the command line, not the wizard. When the user
starts their intake, ask them what they want to work on and which mentors to hire.)
<!-- SETUP_BRIEF_END -->
EOF
ok "wrote CLAUDE.md (agent entry point)"


cat > "$NOTEBOOK_ROOT/.gitignore" <<'EOF'
.DS_Store
._*
*.swp
*~
.trellis/cache/
# Connector secrets — keep these out of any commit
**/*.secret
**/*.local
**/.env
EOF
ok "wrote .gitignore"

# --- record scaffold state for future re-runs / the wizard ----------------
cat > "$NOTEBOOK_ROOT/.trellis/init.env" <<EOF
USER_NAME="$USER_NAME"
WORKSPACE_NAME="$WORKSPACE_NAME"
TIMEZONE="$TIMEZONE"
NOTEBOOK_ROOT="$NOTEBOOK_ROOT"
CLIENT="$CLIENT"
SEASON_NUM="$SEASON_NUM"
SEASON_START="$SEASON_START"
SEASON_END="$SEASON_END"
SEASON_LENGTH_DAYS="$SEASON_LENGTH_DAYS"
WEEKLY_REVIEW_DAY="$WEEKLY_REVIEW_DAY"
TIME_FLOOR_PER_DOMAIN="$TIME_FLOOR_PER_DOMAIN"
TIME_CEILING_PER_DAY="$TIME_CEILING_PER_DAY"
DOMAINS_RAW="$DOMAINS_RAW"
INIT_DATE="$(date +%Y-%m-%d)"
INIT_FRAMEWORK_COMMIT="$(git -C "$FRAMEWORK_ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
EOF
ok "saved scaffold state to .trellis/init.env"

# --- final hint ------------------------------------------------------------
say ""
say "${c_green}Done.${c_reset}"
say ""
say "Next:"
say "  1. ${c_bold}Connect this folder to Claude Cowork${c_reset}  ${c_dim}($NOTEBOOK_ROOT)${c_reset}"
say "  2. ${c_bold}In Cowork, say: \"start my intake\".${c_reset}"
say "     ${c_dim}Your mentors take it from there — they get to know you and${c_reset}"
say "     ${c_dim}do a first piece of real work. No more setup here.${c_reset}"
say ""
say "  ${c_dim}Full step-by-step: docs/quickstart.md${c_reset}"
say ""
