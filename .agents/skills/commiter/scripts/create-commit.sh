#!/usr/bin/env bash
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1

if [[ $# -eq 0 ]]; then
  echo "commit message is required" >&2
  exit 2
fi

fast_mode=0
if [[ "${1:-}" == "--fast" || "${1:-}" == "--no-verify" ]]; then
  fast_mode=1
  shift
fi

if [[ "${1:-}" == -* ]]; then
  echo "unknown option: $1" >&2
  echo "usage: create-commit.sh [--fast|--no-verify] <message>" >&2
  exit 2
fi

message="$*"
if [[ -z "${message// }" ]]; then
  echo "commit message cannot be blank" >&2
  exit 2
fi

if [[ "$fast_mode" -eq 1 ]]; then
  git commit --no-verify -m "$message"
else
  git commit -m "$message"
fi
