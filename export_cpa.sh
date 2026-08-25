#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

usage() {
  cat <<'EOF'
Usage:
  bash export_cpa.sh [accounts.txt] [out_dir] [proxy] [workers]
  cat accounts.txt | bash export_cpa.sh - [out_dir] [proxy] [workers]

Input format:
  email|password|totp
  email2|password2|totp2

Each non-empty, non-comment line is run as one export attempt.

Output format:
  cpa
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

input="${1:-accounts.txt}"
out_dir="${2:-out}"
proxy="${3:-}"
workers="${4:-2}"

python -c "from gpt_tool.ensure_deps import ensure_deps; ensure_deps()"

cmd=(python -m gpt_tool.cli export --format cpa --out "$out_dir" --workers "$workers")
if [ -n "$proxy" ]; then
  cmd+=(--proxy "$proxy")
fi

total=0
ok=0
failed=0

run_attempt() {
  local line="$1"
  local trimmed="${line#"${line%%[![:space:]]*}"}"
  trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

  if [ -z "$trimmed" ] || [[ "$trimmed" == \#* ]]; then
    return 0
  fi

  total=$((total + 1))
  echo
  echo "Attempt #$total: ${trimmed%%|*}"

  if printf '%s\n' "$line" | "${cmd[@]}"; then
    ok=$((ok + 1))
  else
    failed=$((failed + 1))
  fi
}

if [ "$input" = "-" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    run_attempt "$line"
  done
else
  if [ ! -f "$input" ]; then
    echo "Input file not found: $input" >&2
    usage >&2
    exit 2
  fi

  while IFS= read -r line || [ -n "$line" ]; do
    run_attempt "$line"
  done < "$input"
fi

echo
echo "CPA export attempts complete: $ok/$total succeeded, $failed failed. Output: $out_dir"

if [ "$total" -eq 0 ]; then
  echo "No account lines found." >&2
  exit 2
fi

if [ "$failed" -gt 0 ]; then
  exit 1
fi
