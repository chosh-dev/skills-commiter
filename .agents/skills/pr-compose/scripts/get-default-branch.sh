#!/usr/bin/env bash
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1

if ref="$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null)"; then
  echo "${ref#origin/}"
  exit 0
fi

if git show-ref --verify --quiet refs/heads/main || git show-ref --verify --quiet refs/remotes/origin/main; then
  echo "main"
  exit 0
fi

if git show-ref --verify --quiet refs/heads/master || git show-ref --verify --quiet refs/remotes/origin/master; then
  echo "master"
  exit 0
fi

current_branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ -n "$current_branch" && "$current_branch" != "HEAD" ]]; then
  echo "$current_branch"
  exit 0
fi

echo "failed to determine default branch" >&2
exit 2
