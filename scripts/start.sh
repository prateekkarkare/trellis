#!/usr/bin/env bash
# ============================================================================
# Trellis — start here. The ONE command a new user runs.
# ============================================================================
# Opens the visual onboarding wizard in your browser. Click through it to name
# your notebook, pick your mentors, and choose your signals — no terminal, no
# config files. When you finish, your notebook is scaffolded and you're handed
# off to your LLM client to meet your mentors.
#
# Usage:
#   ./scripts/start.sh                       # open the wizard (default notebook ../my-notebook)
#   ./scripts/start.sh --notebook ../my-nb   # choose where your notebook lives
#   ./scripts/start.sh --name "Asha"         # pre-fill your name
#   ./scripts/start.sh --port 8765           # change the local port
#
# Needs python3 (preinstalled on macOS/Linux) for the click-and-done flow.
# Without python3 it still opens the wizard, which hands off via copy-paste.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

NOTEBOOK="../my-notebook"; NAME=""; PORT="8765"; WORKSPACE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --notebook) NOTEBOOK="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --workspace) WORKSPACE="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

# normalize notebook to an absolute path (create parent if needed)
mkdir -p "$(dirname "$NOTEBOOK")" 2>/dev/null || true
NOTEBOOK="$(cd "$(dirname "$NOTEBOOK")" && pwd)/$(basename "$NOTEBOOK")"

c_bold=$'\033[1m'; c_dim=$'\033[2m'; c_green=$'\033[32m'; c_reset=$'\033[0m'

cat <<BANNER

  ┌─────────────────────────────────────────────────────────┐
  │   Trellis — let's set up your mentor team               │
  └─────────────────────────────────────────────────────────┘

BANNER

PY="$(command -v python3 || true)"
if [[ -n "$PY" ]]; then
  echo "  Opening the wizard in your browser…"
  echo "  ${c_dim}Notebook will be created at: $NOTEBOOK${c_reset}"
  echo ""
  TRELLIS_FRAMEWORK="$FRAMEWORK_ROOT" \
  TRELLIS_NOTEBOOK="$NOTEBOOK" \
  TRELLIS_NAME="$NAME" \
  TRELLIS_WORKSPACE="$WORKSPACE" \
  TRELLIS_PORT="$PORT" \
    exec "$PY" "$SCRIPT_DIR/wizard_server.py"
else
  # No python3 — open the static wizard; it hands off via copy-paste.
  echo "  python3 not found — opening the wizard in copy-paste mode."
  echo "  ${c_dim}(The wizard still works; its last screen gives you the exact steps.)${c_reset}"
  WIZ="$FRAMEWORK_ROOT/onboarding/index.html"
  if command -v open >/dev/null 2>&1; then open "$WIZ"
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$WIZ"
  else echo "  Open this file in your browser: $WIZ"; fi
  echo ""
  echo "  ${c_bold}The wizard's final screen will tell you to:${c_reset}"
  echo "    ${c_dim}1. run ./scripts/init.sh (it gives you the exact command)${c_reset}"
  echo "    ${c_dim}2. connect ../my-notebook to Claude Cowork${c_reset}"
  echo "    ${c_dim}3. say \"start my intake\"${c_reset}"
  echo ""
  printf "  %sReady.%s  Full guide: docs/quickstart.md\n\n" "$c_green" "$c_reset"
fi
