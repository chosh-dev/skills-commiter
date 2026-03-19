#!/usr/bin/env bash
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1

has_cached_diff() {
  ! git diff --cached --quiet
}

has_working_tracked_diff() {
  # `git diff` does not include untracked files.
  ! git diff --quiet
}

has_untracked_files() {
  [[ -n "$(git ls-files --others --exclude-standard)" ]]
}

mode() {
  if has_cached_diff; then
    echo "cached"
    return
  fi

  if has_working_tracked_diff; then
    echo "working"
    return
  fi

  echo "none"
}

if [[ "${1:-}" == "--mode" ]]; then
  mode
  exit 0
fi

current_mode="$(mode)"

if [[ "$current_mode" == "cached" ]]; then
  if has_working_tracked_diff || has_untracked_files; then
    echo "staged changes detected; proceeding with cached diff only." >&2
  fi
  git diff --cached --no-color --unified=3
  exit 0
fi

if [[ "$current_mode" == "none" ]]; then
  if has_untracked_files; then
    echo "only untracked files found; stage them to include." >&2
    exit 3
  fi
  echo "No changes (diff) found." >&2
  exit 3
fi

if has_untracked_files; then
  echo "untracked files are not included in working diff; stage them to include." >&2
fi

git diff --no-color --unified=3
