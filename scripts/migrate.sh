#!/usr/bin/env bash
# ============================================================================
# Trellis — Migrate an EXISTING notebook to the current framework (migrate.sh)
# ============================================================================
# Applies a framework update to a populated notebook WITHOUT touching earned
# data. The safe counterpart to init.sh: init.sh scaffolds a NEW notebook and
# substitutes CONFIG.md / mentors/profile.md / season_current.md /
# coordinator_state.md / cross_domain.md, and unconditionally rewrites the
# notebook README.md and CLAUDE.md — re-running it on a real notebook clobbers
# all of that. migrate.sh never writes any of those.
#
# What it DOES:
#   - refresh framework/ copies (PROTOCOLS.md, FIRST_PRINCIPLES.md, WIKI_BRIDGE.md)
#   - install / refresh EVERY file under .claude/skills/<skill>/ (SKILL.md and its
#     companions, e.g. weekly-review/mentor_prompt.md)
#   - add mentors/MEMORY.md from the template IF it is missing (never overwrites)
#   - scaffold new framework dirs (mentors/{coordinator_history,profile_history}/,
#     and sessions/ + archive/ per existing domain) — dirs only, never files
#   - run validate.sh at the end
#
# What it NEVER touches:
#   CONFIG.md · mentors/profile.md · mentors/season_current.md ·
#   mentors/coordinator_state.md · mentors/cross_domain.md · CLAUDE.md ·
#   mentors/MEMORY.md (if it already exists) · any mentors/<domain>/*.md
# Format migrations that need human judgement (the fold line; a root-level
# profile.md) are flagged at the end, not performed.
#
# Usage:
#   ./scripts/migrate.sh --notebook /path/to/notebook
#   ./scripts/migrate.sh --notebook /path/to/notebook --dry-run
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- args -----------------------------------------------------------------
NOTEBOOK=""
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --notebook) NOTEBOOK="$2"; shift 2 ;;
    --dry-run)  DRY_RUN=1; shift ;;
    -h|--help)
      sed -n '2,33p' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ -z "$NOTEBOOK" && -d "$FRAMEWORK_ROOT/../my-notebook" ]] && NOTEBOOK="$(cd "$FRAMEWORK_ROOT/../my-notebook" && pwd)"
[[ -z "$NOTEBOOK" ]] && { echo "migrate.sh: --notebook DIR is required" >&2; exit 1; }
NOTEBOOK="$(cd "$NOTEBOOK" 2>/dev/null && pwd || true)"
[[ -n "$NOTEBOOK" && -d "$NOTEBOOK" ]] || { echo "migrate.sh: notebook dir not found" >&2; exit 1; }

# --- helpers ------------------------------------------------------------------
c_bold=$'\033[1m'; c_dim=$'\033[2m'; c_green=$'\033[32m'; c_yellow=$'\033[33m'; c_red=$'\033[31m'; c_reset=$'\033[0m'
say()  { printf "%s\n" "$*"; }
ok()   { printf "%s✓%s %s\n" "$c_green" "$c_reset" "$*"; }
warn() { printf "%s⚠%s %s\n" "$c_yellow" "$c_reset" "$*"; }
err()  { printf "%s✗%s %s\n" "$c_red" "$c_reset" "$*" >&2; }
run()  { if (( DRY_RUN )); then printf "%s[dry-run]%s %s\n" "$c_dim" "$c_reset" "$*"; else eval "$*"; fi; }

# --- sanity: does this look like a Trellis notebook? -------------------------
if [[ ! -f "$NOTEBOOK/CONFIG.md" || ! -d "$NOTEBOOK/mentors" ]]; then
  err "does not look like a Trellis notebook (need CONFIG.md + mentors/): $NOTEBOOK"
  exit 1
fi

# --- derive substitution values FROM THE NOTEBOOK (never from flags/whoami) --
# CONFIG.md carries them as markdown list items, e.g. "- **USER_NAME**: Kaushal".
cfg_val() { sed -n "s/.*\*\*$1\*\*:[[:space:]]*//p" "$NOTEBOOK/CONFIG.md" | head -1 | sed 's/[[:space:]]*$//'; }
USER_NAME="$(cfg_val USER_NAME)"
WORKSPACE_NAME="$(cfg_val WORKSPACE_NAME)"
[[ -n "$USER_NAME" ]]      || { USER_NAME="$(whoami)";                   warn "USER_NAME not found in CONFIG.md — falling back to '$USER_NAME'"; }
[[ -n "$WORKSPACE_NAME" ]] || { WORKSPACE_NAME="$(basename "$NOTEBOOK")"; warn "WORKSPACE_NAME not found in CONFIG.md — falling back to '$WORKSPACE_NAME'"; }

cat <<BANNER

  ┌─────────────────────────────────────────────────────────┐
  │   Trellis — migrate an existing notebook                 │
  └─────────────────────────────────────────────────────────┘
  notebook : $NOTEBOOK
  user     : $USER_NAME
  workspace: $WORKSPACE_NAME
  mode     : $( ((DRY_RUN)) && echo "DRY RUN (no writes)" || echo "apply" )

BANNER

subst_to() {
  # subst_to <src-abs> <dest-rel-to-notebook>
  local src="$1" dest="$NOTEBOOK/$2"
  [[ -f "$src" ]] || { warn "missing in framework, skipping: $2"; return; }
  if (( DRY_RUN )); then
    printf "%s[dry-run]%s write %s\n" "$c_dim" "$c_reset" "$2"; return
  fi
  mkdir -p "$(dirname "$dest")"
  sed -e "s|{{USER_NAME}}|$USER_NAME|g" -e "s|{{WORKSPACE_NAME}}|$WORKSPACE_NAME|g" "$src" > "$dest"
  ok "refreshed $2"
}

# --- 1. framework/ copies (always refreshed — these are framework, not data) -
say "${c_bold}framework/ copies${c_reset}"
for f in PROTOCOLS.md FIRST_PRINCIPLES.md WIKI_BRIDGE.md; do
  subst_to "$FRAMEWORK_ROOT/core/$f" "framework/$f"
done

# --- 2. skills: every file under each skill dir (SKILL.md + companions) ------
say ""
say "${c_bold}.claude/skills/${c_reset}"
for skill in weekly-review domain-session; do
  skill_src="$FRAMEWORK_ROOT/.claude/skills/$skill"
  [[ -d "$skill_src" ]] || { warn "missing in framework, skipping: .claude/skills/$skill"; continue; }
  while IFS= read -r -d '' src; do
    rel="${src#$skill_src/}"
    subst_to "$src" ".claude/skills/$skill/$rel"
  done < <(find "$skill_src" -type f -print0)
done

# --- 3. mentors/MEMORY.md — create only if missing, NEVER overwrite -------
say ""
say "${c_bold}mentors/MEMORY.md${c_reset}"
if [[ -f "$NOTEBOOK/mentors/MEMORY.md" ]]; then
  ok "already present — left untouched (it holds your rules/facts/asks)"
else
  subst_to "$FRAMEWORK_ROOT/core/MEMORY.md.template" "mentors/MEMORY.md"
  warn "created empty — seed it in conversation from coordinator_state.md / profile.md history"
fi

# --- 4. new scaffold dirs (dirs only, never files) --------------------------
say ""
say "${c_bold}scaffold dirs${c_reset}"
for sub in coordinator_history profile_history; do
  d="$NOTEBOOK/mentors/$sub"
  [[ -d "$d" ]] && continue
  run "mkdir -p '$d'"
  run "touch '$d/.gitkeep'"
  ok "created mentors/$sub/"
done
for d in "$NOTEBOOK"/mentors/*/; do
  [[ -d "$d" ]] || continue
  dname="$(basename "$d")"
  d="${d%/}"
  [[ "$dname" =~ ^(_template|coordinator_history|profile_history)$ ]] && continue
  for sub in sessions archive; do
    [[ -d "$d/$sub" ]] && continue
    run "mkdir -p '$d/$sub'"
    run "touch '$d/$sub/.gitkeep'"
    ok "created mentors/$dname/$sub/"
  done
done

# --- 5. validate ---------------------------------------------------------
say ""
say "${c_bold}validate${c_reset}"
if (( DRY_RUN )); then
  printf "%s[dry-run]%s would run: scripts/validate.sh --notebook %s\n" "$c_dim" "$c_reset" "$NOTEBOOK"
else
  bash "$SCRIPT_DIR/validate.sh" --notebook "$NOTEBOOK" || warn "validate.sh reported issues — review above (see the follow-ups below)"
fi

# --- 6. manual follow-ups --------------------------------------------------
cat <<NOTE

${c_bold}Done.${c_reset} Not touched: CONFIG.md, mentors/profile.md, CLAUDE.md, season_current.md,
coordinator_state.md, cross_domain.md, MEMORY.md (if it existed), every mentors/<domain>/*.md.

Manual follow-ups this script deliberately does NOT do (they need human judgement — a
framework-update script must not rewrite earned prose):
  • The fold. If validate.sh reported "expected exactly one '## ── HISTORY' line", the
    always-read files (MEMORY.md, mentors/profile.md, season_current.md, coordinator_state.md,
    each current_focus.md) predate the fold convention — add the fold line and move history
    below it, in conversation, per core/PROTOCOLS.md → FILE KINDS.
  • profile.md location. If validate.sh reported "mentors/profile.md (missing)" and a
    profile.md sits at the notebook root, move it to mentors/profile.md (that is where
    every protocol now reads it).
  • CLAUDE.md — if it doesn't already point at .claude/skills/ and mentors/MEMORY.md, add
    those pointers by hand (it holds your SETUP_BRIEF, so migrate.sh won't edit it).
  • MEMORY.md — if it was just created, seed RULES/FACTS/ASKS from your history.
  • Run one DRIFT_CHECK per active domain to establish a clean baseline on the new protocol.
NOTE
