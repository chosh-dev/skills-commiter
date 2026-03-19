# skills-commiter

This repository packages `commiter` as a dedicated Codex Agent Skill.
It focuses on making the semantic commit-splitting workflow reusable as a standalone skill package.
Original `commiter` repository: [chosh-dev/commiter](https://github.com/chosh-dev/commiter)

## Why this repo exists

This repo separates the original `commiter` workflow into its own codebase to achieve:

- Reusability: use the same commit planning/apply flow across multiple projects
- Maintainability: version the skill contract (`SKILL.md`) and runner scripts independently
- Safety: force wrapper-script execution instead of composing raw `git` commands in LLM prompts

## Skill contract summary

The core contract is defined in `.agents/skills/commiter/SKILL.md`.

- One-pass execution: analyze/plan first, then ask for a single final apply confirmation
- Plan-first: always show a Commit Plan Summary before applying commits
- Safe execution path: use only `scripts/*.sh` in the workflow
- Rollback support: restore pre-apply staged state via `reset-cached.sh` on failure/abort

## Using this skill in Codex

For Codex to detect this skill, the skill directory must be available in Codex's skill path.

1. Clone this repository.
2. Place (or symlink) `.agents/skills/commiter` into your Codex skills directory.
3. Invoke `$commiter` in a Codex prompt to run the commit split/apply workflow.

Example prompt:

```text
Use $commiter to split current git changes into semantic commits and apply them safely.
```

## Development notes

- Scripts run only inside a Git worktree.
- For LLM/agent integration, prefer wrapper scripts over direct `git ...` execution.
- This repository is focused on skill packaging, so it does not include domain app code or a test framework.

## Typical execution flow

```bash
# 1) Inspect and collect current changes
.agents/skills/commiter/scripts/get-current-diff.sh --mode
.agents/skills/commiter/scripts/get-current-diff.sh

# 2) Collect style anchors from recent commits
.agents/skills/commiter/scripts/get-recent-commits.sh 5

# 3) After plan confirmation, apply patch and create commit
cat planned.patch | .agents/skills/commiter/scripts/apply-patch-cached.sh
.agents/skills/commiter/scripts/create-commit.sh "feat: split X and Y changes"

# 4) On abort/failure, restore staged state from pre-apply snapshot
.agents/skills/commiter/scripts/reset-cached.sh
```

## License

MIT (see `LICENSE`)
