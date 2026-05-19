#!/usr/bin/env bash
# ============================================================================
# Trellis — Interactive Bootstrap (init.sh)
# ============================================================================
# Personalizes the framework and creates a user notebook in a target directory.
# Idempotent: safe to re-run. Existing files are NOT overwritten unless you
# pass --force.
#
# Usage:
#   ./scripts/init.sh                 # interactive
#   ./scripts/init.sh --force         # overwrite existing notebook files
#   ./scripts/init.sh --noninteractive --config path/to/answers.env
# ============================================================================

set -euo pipefail

# --- locate framework root --------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$FRAMEWORK_ROOT"

# --- args -------------------------------------------------------------------
FORCE=0
NONINTERACTIVE=0
CONFIG_FILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --noninteractive) NONINTERACTIVE=1; shift ;;
    --config) CONFIG_FILE="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

# --- helpers ----------------------------------------------------------------
c_bold=$'\033[1m'; c_dim=$'\033[2m'; c_green=$'\033[32m'; c_yellow=$'\033[33m'; c_red=$'\033[31m'; c_reset=$'\033[0m'
say()  { printf "%s\n" "$*"; }
ok()   { printf "%s✓%s %s\n" "$c_green" "$c_reset" "$*"; }
warn() { printf "%s⚠%s %s\n" "$c_yellow" "$c_reset" "$*"; }
err()  { printf "%s✗%s %s\n" "$c_red" "$c_reset" "$*" >&2; }
ask() {
  # ask "Prompt" "default" → echoes answer
  local prompt="$1" default="${2:-}"
  if (( NONINTERACTIVE )); then
    printf "%s\n" "$default"; return
  fi
  local ans
  if [[ -n "$default" ]]; then
    read -r -p "$(printf '%s%s%s [%s]: ' "$c_bold" "$prompt" "$c_reset" "$default")" ans
  else
    read -r -p "$(printf '%s%s%s: ' "$c_bold" "$prompt" "$c_reset")" ans
  fi
  printf "%s\n" "${ans:-$default}"
}

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

# --- collect answers --------------------------------------------------------
USER_NAME="${USER_NAME:-$(ask 'Your name (used in the profile and protocols)' "$(whoami)")}"
WORKSPACE_NAME="${WORKSPACE_NAME:-$(ask 'Workspace name (e.g. "Athena Notebook", "My Mentor Team")' "$USER_NAME's Notebook")}"
TIMEZONE="${TIMEZONE:-$(ask 'Your timezone (IANA, e.g. America/Los_Angeles, Asia/Kolkata)' "$(date +%Z)")}"
NOTEBOOK_ROOT="${NOTEBOOK_ROOT:-$(ask 'Where to create your personal notebook (absolute or relative)' "../my-notebook")}"
NOTEBOOK_ROOT="$(cd "$(dirname "$NOTEBOOK_ROOT")" 2>/dev/null && pwd)/$(basename "$NOTEBOOK_ROOT")" \
  || { mkdir -p "$NOTEBOOK_ROOT"; NOTEBOOK_ROOT="$(cd "$NOTEBOOK_ROOT" && pwd)"; }

CLIENT="${CLIENT:-$(ask 'LLM client driving the system (claude-desktop / claude-code / github-copilot / chatgpt / other)' 'claude-desktop')}"

say ""
say "${c_dim}Initial domains: comma-separated list of life areas you want mentors for.${c_reset}"
say "${c_dim}Examples: fitness, finances, writing, parenting, a-side-project${c_reset}"
DOMAINS_RAW="${DOMAINS_RAW:-$(ask 'Initial domains (comma-separated)' 'fitness, finances, writing')}"
IFS=',' read -r -a DOMAINS <<< "$DOMAINS_RAW"
# trim whitespace and lowercase + slugify
SLUG_DOMAINS=()
for d in "${DOMAINS[@]}"; do
  slug="$(echo "$d" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/[[:space:]]\+/_/g')"
  [[ -n "$slug" ]] && SLUG_DOMAINS+=("$slug")
done

SEASON_NUM="${SEASON_NUM:-$(ask 'Season number to start at' '1')}"
SEASON_LENGTH_DAYS="${SEASON_LENGTH_DAYS:-$(ask 'Season length in days' '90')}"
SEASON_START="${SEASON_START:-$(ask 'Season start date (YYYY-MM-DD)' "$(date +%Y-%m-%d)")}"
# compute season end
if date -v+1d -j -f '%Y-%m-%d' "$SEASON_START" '+%Y-%m-%d' >/dev/null 2>&1; then
  SEASON_END="${SEASON_END:-$(date -v+${SEASON_LENGTH_DAYS}d -j -f '%Y-%m-%d' "$SEASON_START" '+%Y-%m-%d')}"
else
  SEASON_END="${SEASON_END:-$(date -d "$SEASON_START + $SEASON_LENGTH_DAYS days" '+%Y-%m-%d')}"
fi
WEEKLY_REVIEW_DAY="${WEEKLY_REVIEW_DAY:-$(ask 'Day of week for the weekly review' 'Sunday')}"
MENTOR_REFRESH_WEEKS="${MENTOR_REFRESH_WEEKS:-$(ask 'Mentor intel refresh cadence (weeks)' '4')}"
TIME_FLOOR_PER_DOMAIN="${TIME_FLOOR_PER_DOMAIN:-$(ask 'Time floor per active domain per week (min)' '90')}"
TIME_CEILING_PER_DAY="${TIME_CEILING_PER_DAY:-$(ask 'Time ceiling for mentor sessions per weekday (min)' '180')}"
COMM_TONE="${COMM_TONE:-$(ask 'Communication tone 1-5 (1=gentle, 5=ruthless)' '3')}"
COMM_FORMAT="${COMM_FORMAT:-$(ask 'Default response format (bullets/prose/tables/mixed)' 'mixed')}"

say ""
say "${c_dim}Protocol mode controls how long-running protocols (WEEKLY_REVIEW,${c_reset}"
say "${c_dim}MONTHLY_REVIEW, SEASON_TRANSITION) behave:${c_reset}"
say "${c_dim}  checkpoints  — mentor pauses at each gate for your approval (safer, recommended)${c_reset}"
say "${c_dim}  automated    — mentor runs end-to-end without pausing and delivers a single final report${c_reset}"
PROTOCOL_MODE="${PROTOCOL_MODE:-$(ask 'Protocol mode (checkpoints/automated)' 'checkpoints')}"
case "$PROTOCOL_MODE" in
  checkpoints|automated) ;;
  *) warn "unknown PROTOCOL_MODE '$PROTOCOL_MODE' — falling back to 'checkpoints'"; PROTOCOL_MODE="checkpoints" ;;
esac

# --- summarize and confirm --------------------------------------------------
say ""
say "${c_bold}Summary${c_reset}"
say "  User:           $USER_NAME"
say "  Workspace:      $WORKSPACE_NAME"
say "  Notebook root:  $NOTEBOOK_ROOT"
say "  Client:         $CLIENT"
say "  Domains:        ${SLUG_DOMAINS[*]}"
say "  Season:         #$SEASON_NUM, $SEASON_START → $SEASON_END (${SEASON_LENGTH_DAYS}d)"
say "  Weekly review:  ${WEEKLY_REVIEW_DAY}s"
say "  Protocol mode:  ${PROTOCOL_MODE}"
say ""

if (( ! NONINTERACTIVE )); then
  confirm="$(ask 'Proceed? (yes/no)' 'yes')"
  [[ "$confirm" =~ ^[Yy] ]] || { warn "aborted by user"; exit 0; }
fi

# --- create notebook tree ---------------------------------------------------
mkdir -p "$NOTEBOOK_ROOT"/{mentors,coordinator_history}
mkdir -p "$NOTEBOOK_ROOT"/.trellis

# --- substitution helper ----------------------------------------------------
# Build multi-line replacement blocks in temp files (avoids BSD awk's
# "newline in string" error when passing multi-line vars via -v).
SUBST_TMP="$(mktemp -d -t trellis-subst.XXXXXX)"
trap 'rm -rf "$SUBST_TMP"' EXIT
{
  for d in "${SLUG_DOMAINS[@]}"; do
    printf -- "- %s (Active)\n" "$d"
  done
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

# --- copy framework docs (read-only references — symlinked, not copied) -----
mkdir -p "$NOTEBOOK_ROOT/framework"
for f in FIRST_PRINCIPLES.md PROTOCOLS.md WIKI_BRIDGE.md; do
  cp "$FRAMEWORK_ROOT/core/$f" "$NOTEBOOK_ROOT/framework/$f"
  ok "wrote framework/$f"
done

# --- personalized top-level files -----------------------------------------
substitute "$FRAMEWORK_ROOT/core/CONFIG.md.template"            "$NOTEBOOK_ROOT/CONFIG.md"
substitute "$FRAMEWORK_ROOT/core/profile.md.template"           "$NOTEBOOK_ROOT/profile.md"
substitute "$FRAMEWORK_ROOT/core/season_current.md.template"    "$NOTEBOOK_ROOT/mentors/season_current.md"
substitute "$FRAMEWORK_ROOT/core/coordinator_state.md.template" "$NOTEBOOK_ROOT/mentors/coordinator_state.md"
substitute "$FRAMEWORK_ROOT/core/cross_domain.md.template"      "$NOTEBOOK_ROOT/mentors/cross_domain.md"

# --- create each domain from template -------------------------------------
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
  ok "created mentors/$d/"
done

# --- write user notebook README -------------------------------------------
cat > "$NOTEBOOK_ROOT/README.md" <<EOF
# $WORKSPACE_NAME

A personal mentor's-notebook built on [Trellis](https://github.com/your/Trellis).

## Files

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
"Let's do a session on $(echo "${SLUG_DOMAINS[0]:-fitness}")"
"Weekly review"
"Refresh the mentors"
"Season review"

# Add a new domain mentor:
cd $(realpath --relative-to="$NOTEBOOK_ROOT" "$FRAMEWORK_ROOT" 2>/dev/null || echo "<Trellis>")
./scripts/add-domain.sh <new_domain_slug> --notebook "$NOTEBOOK_ROOT"
\`\`\`

## Next steps

1. Open \`mentors/season_current.md\` and fill in the *why this season* / *exit criterion* for each domain.
2. Open \`CONFIG.md\` and tune anything that init.sh got wrong.
3. In your LLM client, paste the contents of \`framework/PROTOCOLS.md\` as the system prompt (or attach this folder as a Project — see \`framework/\` or the original Trellis repo's \`docs/client-setup/\`).
4. Start your first session.

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

# --- write a starter .gitignore in the notebook ---------------------------
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

# --- record init state for future re-runs ---------------------------------
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
MENTOR_REFRESH_WEEKS="$MENTOR_REFRESH_WEEKS"
TIME_FLOOR_PER_DOMAIN="$TIME_FLOOR_PER_DOMAIN"
TIME_CEILING_PER_DAY="$TIME_CEILING_PER_DAY"
COMM_TONE="$COMM_TONE"
COMM_FORMAT="$COMM_FORMAT"
PROTOCOL_MODE="$PROTOCOL_MODE"
DOMAINS_RAW="$DOMAINS_RAW"
INIT_DATE="$(date +%Y-%m-%d)"
INIT_FRAMEWORK_COMMIT="$(git -C "$FRAMEWORK_ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
EOF
ok "saved init state to .trellis/init.env (re-runnable with --noninteractive --config .trellis/init.env)"

# --- final hint ------------------------------------------------------------
say ""
say "${c_green}Done.${c_reset}"
say ""
say "Next:"
say "  1. ${c_bold}cd \"$NOTEBOOK_ROOT\"${c_reset}"
say "  2. ${c_bold}cat README.md${c_reset}"
say "  3. Point your LLM client at this folder. See: ${c_dim}$FRAMEWORK_ROOT/docs/client-setup/${CLIENT}.md${c_reset}"
say ""
