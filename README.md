# skills

This repository is a Codex Agent Skill monorepo.
It currently includes `commiter` and `pr-compose`, and is structured to manage multiple skills in one place.
Original `commiter` repository: [chosh-dev/commiter](https://github.com/chosh-dev/commiter)

## Why this repo exists

This repo packages reusable skills to achieve:

- Reusability: keep operational workflows as installable skills
- Maintainability: version each skill contract (`SKILL.md`) and runner scripts independently
- Safety: force wrapper-script execution instead of composing raw `git` commands in LLM prompts

## Skill contract summary

Core contracts are defined per skill:

- `.agents/skills/commiter/SKILL.md`
  - One-pass execution: analyze/plan first, then ask for a single final apply confirmation
  - Hunk-level precision: split mixed changes into fine-grained commit units when needed
  - Plan-first: always show a Commit Plan Summary before applying commits
  - Safe execution path: use only `scripts/*.sh` in the workflow
  - Rollback support: restore pre-apply staged state via `reset-cached.sh` on failure/abort
- `.agents/skills/pr-compose/SKILL.md`
  - PR compose package flow optimized for concise review
  - GitHub host-aware compose link generation from `origin`
  - Title format enforced as English conventional prefix (`feat:`, `refactor:`, `chore:`)
  - Body format fixed to `Summary`, `Description`, `Related`

## Using skills in Codex

For Codex to detect a skill, the skill directory must be available in Codex's skill path.

1. Clone this repository.
2. Place (or symlink) `.agents/skills/<skill-name>` into your Codex skills directory.
3. Invoke `$<skill-name>` in a Codex prompt.

Example prompt:

```text
Use $commiter to split current git changes into semantic commits and apply them safely.
```

```text
Use $pr-compose to generate a GitHub PR compose link, title, and body from current branch changes.
```

## Install with skills CLI

You can install directly from GitHub:

```bash
npx -y skills add chosh-dev/skills --skill commiter
```

If the repo has multiple skills, add each one explicitly:

```bash
npx -y skills add chosh-dev/skills --skill commiter
npx -y skills add chosh-dev/skills --skill pr-compose
```

You can also use `<repo>@<skill-name>` form:

```bash
npx -y skills add chosh-dev/skills@commiter
npx -y skills add chosh-dev/skills@pr-compose
```

Validate this repository locally before publishing:

```bash
npx -y skills add . --list
```

## Add more skills to this repo

Register additional skills under `.agents/skills`:

```text
.agents/skills/
  commiter/
    SKILL.md
    scripts/*
  pr-compose/
    SKILL.md
    scripts/*
```

Each skill is independently installable with `npx -y skills add <owner>/<repo> --skill <skill-name>`.

## Development notes

- Scripts run only inside a Git worktree.
- For LLM/agent integration, prefer wrapper scripts over direct `git ...` execution.
- This repository is focused on skill packaging, so it does not include domain app code or a test framework.

## Typical execution flow

```bash
# 1) Collect diff + style anchors in one shot
.agents/skills/commiter/scripts/get-current-diff.sh &
.agents/skills/commiter/scripts/get-recent-commits.sh 5

# 3) After plan confirmation, apply patch and create commit
cat planned.patch | .agents/skills/commiter/scripts/apply-patch-cached.sh
.agents/skills/commiter/scripts/create-commit.sh "feat: split X and Y changes"

# 4) On abort/failure, restore staged state from pre-apply snapshot
.agents/skills/commiter/scripts/reset-cached.sh
```

## License

MIT (see `LICENSE`)
