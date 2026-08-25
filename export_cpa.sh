#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

usage() {
  cat <<'EOF'
Usage:
  ./export_cpa.bash accounts.txt [out_dir] [proxy] [workers]
  cat accounts.txt | ./export_cpa.bash - [out_dir] [proxy] [workers]

Input format:
  email|password|totp

Output format:
  cpa
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

input="${1:-}"
out_dir="${2:-out}"
proxy="${3:-}"
workers="${4:-2}"

if [ -z "$input" ]; then
  usage >&2
  exit 2
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Python 3.11+ is required. Download: https://www.python.org/downloads/" >&2
  exit 1
fi

if ! python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 11) else 1)'; then
  echo "Python 3.11+ is required." >&2
  exit 1
fi

if [ ! -d .venv ]; then
  echo "Creating virtual environment (.venv)..."
  python3 -m venv .venv
fi

# shellcheck disable=SC1091
source .venv/bin/activate

echo "Installing/updating dependencies..."
python -m pip install -q -U pip
python -m pip install -q -U -r requirements.txt
python -c "from gpt_tool.ensure_deps import ensure_deps; ensure_deps()"

cmd=(python -m gpt_tool.cli export --format cpa --out "$out_dir" --workers "$workers")
if [ -n "$proxy" ]; then
  cmd+=(--proxy "$proxy")
fi

if [ "$input" = "-" ]; then
  "${cmd[@]}"
else
  "${cmd[@]}" --lines "$input"
fi
