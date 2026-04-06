---
name: pr-compose
description: Prepare a concise GitHub PR compose package from the current conversation thread. Use thread-agreed final outcomes as the primary source, resolve the GitHub host from origin for link generation, and provide a PR creation link plus an English conventional title (`feat:`, `refactor:`, `chore:`) and a thread-language body using `Summary/Description/Related`.
---

# PR Compose

Prepare PR inputs with a review-friendly format and minimal noise.

## Default Runbook

### 1. Collect PR context

- Read the current conversation thread first and extract agreed final outcomes.
- Build the PR narrative from thread decisions, not from command execution logs.
- Use repo commands only for link construction inputs (base/head/host) or to resolve ambiguities.
- Resolve base branch with `scripts/get-default-branch.sh`.
- Resolve head branch with `git rev-parse --abbrev-ref HEAD`.
- Detect GitHub host/repository from `origin`.

### 2. Build title (English)

- Format: `<type>: <short imperative summary>`.
- Allowed types: `feat`, `refactor`, `chore`.
- Title must be English.
- Prefer one concise clause without unnecessary details.

Examples:

- `feat: add Google and PEM key detection patterns`
- `refactor: move ESLint local rules into eslintConfig package`
- `chore: align secret scan rule names`

### 3. Build body (thread language)

Use this exact section structure:

```markdown
## Summary

## Description

## Related
```

Formatting rules:

- Keep the whole body concise and scannable.
- `Summary`: one line per major change group (prefer 2-3 lines total).
- `Description`: numbered subsections (`### 1.`, `### 2.`) with short bullets focused on final outcomes.
- Avoid step-by-step process logs; write what changed and why it matters now.
- Mention failed attempts or workaround history only when it explains the final design decision.
- Prefer "final state" phrasing over "what was tried during implementation."
- Use an `as-is / to-be` table only when it improves clarity; skip it otherwise.
- A single table in `Description` is allowed when it replaces longer prose.
- `Related`: include links only when they add decision context; otherwise keep the section empty.

### 4. Preview package

Show base/head/title and the final markdown body.

### 5. Build PR compose link

- Save body to a temp markdown file and run:

```bash
scripts/create-pr-link.sh "<title>" "<body-file>" [base] [head]
```

- Script behavior: validates title/body shape, resolves GitHub host from `origin`, and prints link/title/body.
- On blockers (for example `head == base`), still print the compare root guidance link (`https://<host>/<repo>/compare`).

## Hard Rules

- Base branch must default to repo default branch unless user explicitly overrides.
- Do not auto-expand into long prose; prioritize review speed.
- Thread context is the source of truth for `Summary`/`Description` when available.
- Do not echo terminal command history in PR body.
- Do not include implementation trivia in `Summary`.
- Do not narrate chronological trial-and-error unless it is required context for reviewers.
- If there are no commits ahead of base, stop and report blocker.
- Always verify the remote host is GitHub-compatible before building the link.
- Keep `title` English even when body language is non-English.
