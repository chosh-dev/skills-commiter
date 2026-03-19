#!/usr/bin/env bash
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1
state_file="$(git rev-parse --git-path commiter-prev-index-tree)"

if [[ -f "$state_file" ]]; then
  tree="$(<"$state_file")"
  if [[ -z "${tree// }" ]]; then
    echo "snapshot file is empty: $state_file" >&2
    exit 2
  fi

  git read-tree "$tree"
  rm -f "$state_file"
  exit 0
fi

echo "no staged snapshot found; skip restoring cached state." >&2
