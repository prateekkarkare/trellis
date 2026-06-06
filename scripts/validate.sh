#!/usr/bin/env bash
# ============================================================================
# Trellis — Validate a notebook's structure
# ============================================================================
# Checks for the files and folders the protocols expect. Reports drift.
# Does NOT modify anything.
#
# Usage: ./scripts/validate.sh [--notebook /path/to/notebook]
# ============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

NOTEBOOK=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --notebook) NOTEBOOK="$2"; shift 2 ;;
    -h|--help) echo "usage: $0 [--notebook DIR]"; exit 0 ;;
    *) echo "unknown arg: $1"; exit 1 ;;
  esac
done

[[ -z "$NOTEBOOK" && -d "$FRAMEWORK_ROOT/../my-notebook" ]] && NOTEBOOK="$(cd "$FRAMEWORK_ROOT/../my-notebook" && pwd)"
[[ -z "$NOTEBOOK" ]] && { read -r -p "Path to notebook: " NOTEBOOK; }

c_red=$'\033[31m'; c_green=$'\033[32m'; c_yellow=$'\033[33m'; c_reset=$'\033[0m'
fails=0; warns=0

check_file() {
  if [[ -f "$NOTEBOOK/$1" ]]; then
    printf "%s✓%s %s\n" "$c_green" "$c_reset" "$1"
  else
    printf "%s✗%s %s (missing)\n" "$c_red" "$c_reset" "$1"; fails=$((fails+1))
  fi
}

check_dir() {
  if [[ -d "$NOTEBOOK/$1" ]]; then
    printf "%s✓%s %s/\n" "$c_green" "$c_reset" "$1"
  else
    printf "%s✗%s %s/ (missing)\n" "$c_red" "$c_reset" "$1"; fails=$((fails+1))
  fi
}

warn_if_unsub() {
  if grep -l '{{[A-Z_]*}}' "$NOTEBOOK/$1" 2>/dev/null >/dev/null; then
    printf "%s⚠%s %s contains unsubstituted {{PLACEHOLDERS}}\n" "$c_yellow" "$c_reset" "$1"; warns=$((warns+1))
  fi
}

echo "Validating notebook at: $NOTEBOOK"
echo "---"

# Top-level
for f in CLAUDE.md CONFIG.md profile.md README.md; do check_file "$f"; warn_if_unsub "$f"; done

# Mentors
for f in mentors/season_current.md mentors/coordinator_state.md mentors/cross_domain.md; do
  check_file "$f"; warn_if_unsub "$f"
done

# Framework copies
for f in framework/FIRST_PRINCIPLES.md framework/PROTOCOLS.md framework/WIKI_BRIDGE.md; do
  check_file "$f"
done

# Per-domain
for d in "$NOTEBOOK"/mentors/*/; do
  [[ -d "$d" ]] || continue
  dname="$(basename "$d")"
  [[ "$dname" =~ ^(_template|coordinator_history)$ ]] && continue
  echo "---"
  echo "domain: $dname"
  for f in README.md current_focus.md done_topics.md intel.md curriculum.md log.md; do
    check_file "mentors/$dname/$f"
  done
  check_dir "mentors/$dname/sessions"
  check_dir "mentors/$dname/archive"
done

echo "---"
if (( fails == 0 && warns == 0 )); then
  printf "%sAll checks passed.%s\n" "$c_green" "$c_reset"
  exit 0
elif (( fails == 0 )); then
  printf "%s%d warning(s).%s\n" "$c_yellow" "$warns" "$c_reset"; exit 0
else
  printf "%s%d failure(s), %d warning(s).%s\n" "$c_red" "$fails" "$warns" "$c_reset"; exit 1
fi
