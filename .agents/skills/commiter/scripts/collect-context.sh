#!/usr/bin/env bash
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
recent_limit="${1:-5}"

echo "=== CONTEXT:DIFF ==="
"$script_dir/get-current-diff.sh"
echo
echo "=== CONTEXT:RECENT_COMMITS ==="
"$script_dir/get-recent-commits.sh" "$recent_limit"
