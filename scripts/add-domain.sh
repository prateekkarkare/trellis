#!/usr/bin/env bash
# ============================================================================
# Trellis — Add a new domain mentor to an existing notebook
# ============================================================================
# Usage:
#   ./scripts/add-domain.sh <domain_slug> [--notebook /path/to/notebook] [--force]
#
# If --notebook is omitted, looks for ../my-notebook then prompts.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DOMAIN=""
NOTEBOOK=""
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --notebook) NOTEBOOK="$2"; shift 2 ;;
    --force)    FORCE=1; shift ;;
    -h|--help)
      echo "usage: $0 <domain_slug> [--notebook DIR] [--force]"; exit 0 ;;
    -*) echo "unknown arg: $1" >&2; exit 1 ;;
    *)  DOMAIN="$1"; shift ;;
  esac
done

if [[ -z "$DOMAIN" ]]; then
  read -r -p "Domain slug (lowercase, underscores): " DOMAIN
fi

# slugify
DOMAIN="$(echo "$DOMAIN" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/[[:space:]]\+/_/g')"
[[ -n "$DOMAIN" ]] || { echo "empty domain"; exit 1; }

# locate notebook
if [[ -z "$NOTEBOOK" ]]; then
  if [[ -d "$FRAMEWORK_ROOT/../my-notebook" ]]; then
    NOTEBOOK="$(cd "$FRAMEWORK_ROOT/../my-notebook" && pwd)"
  else
    read -r -p "Path to your notebook: " NOTEBOOK
  fi
fi
[[ -d "$NOTEBOOK/mentors" ]] || { echo "not a Trellis notebook (no mentors/ dir): $NOTEBOOK"; exit 1; }

DOMDIR="$NOTEBOOK/mentors/$DOMAIN"
if [[ -d "$DOMDIR" && $FORCE -eq 0 ]]; then
  echo "domain already exists: $DOMDIR (use --force to overwrite)" >&2
  exit 1
fi

# load init state for USER_NAME
USER_NAME="$(whoami)"
if [[ -f "$NOTEBOOK/.trellis/init.env" ]]; then
  # shellcheck disable=SC1091
  source "$NOTEBOOK/.trellis/init.env"
fi

mkdir -p "$DOMDIR/sessions" "$DOMDIR/archive"
for f in README.md current_focus.md done_topics.md intel.md curriculum.md log.md; do
  sed -e "s|<domain>|$DOMAIN|g" -e "s|{{USER_NAME}}|$USER_NAME|g" \
      "$FRAMEWORK_ROOT/templates/domain/$f" > "$DOMDIR/$f"
done
touch "$DOMDIR/sessions/.gitkeep" "$DOMDIR/archive/.gitkeep"

cat <<MSG
✓ created mentors/$DOMAIN/ (needs intake)

Next — in your LLM client, say:
    "Hire the $DOMAIN mentor"
That runs the mentor's first conversation (INTAKE Part B): it learns your goals,
baseline, and constraints for $DOMAIN, adds the season_current.md row, populates
curriculum.md / current_focus.md, and ends with one real piece of work.

(You don't normally need this script — during intake, just say "hire a <domain>
mentor" and the mentor creates the folder for you.)
MSG
