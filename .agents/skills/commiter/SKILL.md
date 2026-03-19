---
name: commiter
description: Create and execute semantic git commit plans from staged or unstaged diffs via `scripts/*.sh` wrappers. Use when Codex should split a mixed diff into scoped commits, validate hunk coverage, show a commit summary, and apply commits safely with a single confirmation.
---

# Commiter

Execute in one pass. Ask only one final apply confirmation unless a hard blocker appears.

## Default Runbook

### 1. Collect context.

```bash
scripts/collect-context.sh 5
```

- This single command prints both sections required for planning:
- `CONTEXT:DIFF`: hunk-level code diff (prefers cached diff; otherwise uses working tracked diff).
- `CONTEXT:RECENT_COMMITS`: the most recent 5 commits (format: `hash<US>subject<RS>`).

### 2. Build semantic commit units

- Keep one logical purpose per commit.
- Order commits by dependency (prerequisite first).
- Separate mechanical refactor from behavior change when possible.
- Follow recent commit style from `scripts/get-recent-commits.sh 5`.

### 3. Present the plan

- Print Commit Plan Summary before any apply action.
- If edits are needed, request message changes in the same reply.

### 4. Ask once for apply mode

- `cancel`: abort without applying
- `normal`: run hooks
- `fast`: skip git hooks (use '--no-verify' in git commit)

### 5. Apply with wrappers only

```bash
scripts/apply-patch-cached.sh
scripts/create-commit.sh [--fast] "<message>"
```

### 6. Recover on abort/failure

```bash
scripts/reset-cached.sh
```

`apply-patch-cached.sh` snapshots the index first, and `reset-cached.sh` restores that snapshot.

## Hard Rules

- Use `scripts/*.sh` only; do not run raw `git ...` in workflow steps.
- Prefer read-only collection commands during planning to avoid permission prompts.
- Preserve user-confirmed messages and ordering.
- Do not auto-commit without explicit user confirmation unless user requested non-interactive execution.
- Use `--fast` only when user explicitly chose `fast`.
- If user chose `cancel`, stop without applying patches or commits.
- After apply mode confirmation, run only commands required to apply commits.
- Do not run `scripts/get-recent-commits.sh` or `scripts/get-current-diff.sh --mode` after apply unless requested or needed for failure diagnosis.
- Keep output deterministic and auditable: plan first, apply second.
- Preserve commit numbering as execution order in plan output.

## Diff Selection

- If staged changes exist, use cached diff only and ignore unstaged/untracked for planning.
- If staged changes do not exist, use working tracked diff.
- Exclude untracked files from working diff until they are staged.

## Chat Rules

- Keep chat minimal and execution-first.
- Do not narrate intent before read-only collection commands.
- Keep pre-plan chat to at most one short status line, only when execution is noticeably slow.
- After user selects `normal` or `fast`, execute immediately without preface text.
- If user selects `cancel`, end the flow without extra processing.
- Do not announce follow-up checks (for example recent commits or diff mode) unless user explicitly asked for verification logs.
- Avoid command-by-command chat logs unless user asked for verbose output.

## Commit Plan Output Format

- Match the original commiter terminal summary style.
- Use compact summary layout with separators and per-file stats.
- Print one file per line. Do not print file paths as one comma-separated line.
- Show per-file line stats as `+<added> -<deleted>`.
- If ANSI color is supported, render header in cyan, divider in dim gray, `+` stat in green, and `-` stat in red.

Use:

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
