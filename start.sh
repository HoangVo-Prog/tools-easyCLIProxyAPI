#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3.11+ is required. Download it at https://www.python.org/downloads/"
  exit 1
fi
if ! python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)'; then
  echo "Python 3.11+ is required (current: $(python3 -c 'import sys; print(sys.version.split()[0])'))"
  echo "Download it at https://www.python.org/downloads/"
  exit 1
fi

if [ ! -d .venv ]; then
  echo "Creating virtual environment (.venv)..."
  python3 -m venv .venv
fi

# shellcheck disable=SC1091
source .venv/bin/activate
echo "Installing/updating dependencies (first run may take 1-2 minutes)..."
python -m pip install -q -U pip
python -m pip install -q -U -r requirements.txt
python -c "from gpt_tool.ensure_deps import ensure_deps; ensure_deps()"
echo "Opening GPT-Tool in your browser..."
exec python -m gpt_tool.server
