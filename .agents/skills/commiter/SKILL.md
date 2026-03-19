---
name: commiter
description: Create and execute semantic git commit plans from staged or unstaged diffs via `scripts/*.sh` wrappers. Use when Codex should split a mixed diff into scoped commits, validate hunk coverage, show a commit summary, and apply commits safely with a single confirmation.
---

# Commiter

## Overview

Run the workflow in a single pass with minimal user ping-pong.
Ask only once at final apply confirmation unless a hard blocker appears.

## Workflow

1. Collect context in one command:

```bash
scripts/collect-context.sh 5
```

2. (Optional fallback) Run separately only when debugging:

```bash
scripts/get-current-diff.sh
scripts/get-recent-commits.sh 5
```

3. Apply commit patch and commit message units:

```bash
scripts/apply-patch-cached.sh
scripts/create-commit.sh [--fast] "<message>"
```

4. Roll back staged state on abort/failure:

```bash
scripts/reset-cached.sh
```

`apply-patch-cached.sh` snapshots the current index first, and `reset-cached.sh` restores that snapshot.

## Interaction Contract

- Keep execution one-pass: run analysis and plan generation first, then ask exactly one final confirmation to apply.
- At final confirmation, ask apply mode together: `normal` (run hooks) or `fast` (--no-verify).
- Start execution first, then report results. Do not send "I will do X" intent narration before read-only collection commands.
- Keep pre-plan chat minimal: at most one short status line, and only if command execution is noticeably slow.
- Avoid ping-pong status spam: do not list every command run as separate chat lines unless the user explicitly requests verbose logs.
- Prefer read-only diff collection to avoid permission prompts in sandboxed environments.
- `get-current-diff.sh` uses cached diff only when staged changes exist (ignores unstaged/untracked), otherwise falls back to working diff.
- Untracked files are not included in working diff; stage them first to include.

## Commit Plan Output Format

Match the original commiter terminal summary style.
Use a compact "Commit Plan Summary" layout with separators and per-file stats.
Do not print file paths in a single comma-separated line.
Print one file per line.
Show line stats per file as `+<added> -<deleted>`.
If ANSI color is supported, render:

- header in cyan
- divider in dim gray
- `+` stat in green
- `-` stat in red

Use this format:

```text
---
=== Commit Plan Summary ===
Total commits: <N>
Total files: <F> | `+<A>` `-<D>`

---
[1/N] <type>: <message>
  - <path1> `+<added>` `-<deleted>`
  - <path2> `+<added>` `-<deleted>`
  - <path3> `+<added>` `-<deleted>`

---
[2/N] <type>: <message>
  - <path4> `+<added>` `-<deleted>`

---
```

If the user needs edits, ask for message changes in the same reply without extra intermediate steps.

## Commit Rules

- One commit = one logical purpose (do not mix unrelated changes).
- Order by dependency: prerequisite first, consumer later (no forward dependency).
- Separate mechanical refactor from behavior change when possible.
- Follow the message style from `scripts/get-recent-commits.sh 5`; keep wording clear and concise.

## Operating Rules

- Route all shell execution through `scripts/*.sh`; do not type raw `git ...` in workflow steps.
- Execute end-to-end in one turn; avoid intermediate confirmation questions.
- Preserve user intent; do not rewrite commit messages after confirmation.
- Do not auto-commit without explicit user confirmation unless user requested non-interactive execution.
- Use `scripts/create-commit.sh --fast "<message>"` only when user explicitly chose fast mode.
- Keep output deterministic and auditable: plan first, apply second.
- In plan output, preserve commit numbering as execution order and keep messages/order rationale consistent with that order.
- On abort/failure, use `scripts/reset-cached.sh` to restore the pre-apply staged state (do not use raw `git reset`).
