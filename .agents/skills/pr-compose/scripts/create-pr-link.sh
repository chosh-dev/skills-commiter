#!/usr/bin/env bash
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  echo "usage: create-pr-link.sh <title> <body-file> [base] [head]" >&2
}

urlencode() {
  python3 - "$1" <<'PY'
import sys
from urllib.parse import quote
print(quote(sys.argv[1], safe='-._~'))
PY
}

parse_origin() {
  local origin_url="$1"
  local parsed_host=""
  local parsed_repo=""

  if [[ "$origin_url" =~ ^git@([^:]+):(.+)$ ]]; then
    parsed_host="${BASH_REMATCH[1]}"
    parsed_repo="${BASH_REMATCH[2]}"
  elif [[ "$origin_url" =~ ^ssh://git@([^/]+)/(.+)$ ]]; then
    parsed_host="${BASH_REMATCH[1]}"
    parsed_repo="${BASH_REMATCH[2]}"
  elif [[ "$origin_url" =~ ^https?://([^/]+)/(.+)$ ]]; then
    parsed_host="${BASH_REMATCH[1]}"
    parsed_repo="${BASH_REMATCH[2]}"
  else
    echo "unsupported origin url format: $origin_url" >&2
    return 1
  fi

  parsed_repo="${parsed_repo%.git}"
  parsed_repo="${parsed_repo#/}"

  if [[ "$parsed_host" != *github* ]]; then
    echo "origin host is not GitHub-compatible: $parsed_host" >&2
    return 1
  fi

  printf '%s\n%s\n' "$parsed_host" "$parsed_repo"
}

fail() {
  local message="$1"
  echo "$message" >&2
  if [[ -n "${compare_root:-}" ]]; then
    echo "fallback_compare_link=${compare_root}"
  fi
  exit 2
}

if [[ $# -lt 2 || $# -gt 4 ]]; then
  usage
  exit 2
fi

title="$1"
body_file="$2"
base="${3:-$($script_dir/get-default-branch.sh)}"
head="${4:-$(git rev-parse --abbrev-ref HEAD)}"

if ! origin_url="$(git remote get-url origin 2>/dev/null)"; then
  fail "origin remote is required"
fi

if ! origin_parsed="$(parse_origin "$origin_url")"; then
  exit 2
fi
host="$(printf '%s\n' "$origin_parsed" | sed -n '1p')"
repo_path="$(printf '%s\n' "$origin_parsed" | sed -n '2p')"
compare_root="https://${host}/${repo_path}/compare"

if [[ "$head" == "HEAD" ]]; then
  fail "detached HEAD is not supported"
fi

if [[ "$head" == "$base" ]]; then
  fail "head branch must differ from base branch"
fi

if ! printf '%s\n' "$title" | grep -Eq '^(feat|refactor|chore)(\([^)]+\))?: .+'; then
  fail "title must follow: feat|refactor|chore: <summary>"
fi

if printf '%s' "$title" | LC_ALL=C grep -q '[^ -~]'; then
  fail "title must be English ASCII text"
fi

if [[ ! -f "$body_file" ]]; then
  fail "body file not found: $body_file"
fi

for section in "## Summary" "## Description" "## Related"; do
  if ! grep -q "^${section}$" "$body_file"; then
    fail "body must include section: ${section}"
  fi
done

base_ref=""
if git show-ref --verify --quiet "refs/heads/$base"; then
  base_ref="$base"
elif git show-ref --verify --quiet "refs/remotes/origin/$base"; then
  base_ref="origin/$base"
else
  fail "base branch reference not found: $base"
fi

if [[ "$(git rev-list --count "${base_ref}..${head}")" -eq 0 ]]; then
  fail "no commits ahead of ${base} on ${head}"
fi

body="$(cat "$body_file")"
base_enc="$(urlencode "$base")"
head_enc="$(urlencode "$head")"
title_enc="$(urlencode "$title")"
body_enc="$(urlencode "$body")"

link="${compare_root}/${base_enc}...${head_enc}?expand=1&title=${title_enc}&body=${body_enc}"

echo "link=${link}"
echo "title=${title}"
echo "body<<EOF"
cat "$body_file"
echo "EOF"
