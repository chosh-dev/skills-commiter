#!/usr/bin/env bash
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1
state_file="$(git rev-parse --git-path commiter-prev-index-tree)"
baseline_tree="$(git write-tree)"
printf '%s\n' "$baseline_tree" > "$state_file"

git apply --cached --unidiff-zero --whitespace=nowarn -
