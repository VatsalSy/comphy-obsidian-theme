---
name: theme-github-release
description: Automate publishing a new GitHub release for this `comphy-obsidian-theme` repository by bumping version fields, rebuilding `theme.css`, committing release artifacts, tagging, pushing, and creating a GitHub release with `gh`. Use when asked to cut, publish, ship, or tag a new theme version, including manual release requests that should be converted into a repeatable workflow.
---

# Theme GitHub Release

Publish this theme reliably by using the bundled script instead of manual tag/release steps.

## Quick Start

Run from repository root:

```bash
bash .agents/skills/theme-github-release/scripts/create_release.sh 1.0.2
```

Dry-run without changing files:

```bash
bash .agents/skills/theme-github-release/scripts/create_release.sh 1.0.2 --dry-run --skip-remote-checks
```

## Workflow

1. Ensure the working tree is clean and required files exist.
2. Update release versions in `manifest.json`, `package.json`, and `versions.json`.
3. Rebuild distributable CSS with `bash scripts/build-theme.sh`.
4. Run CSS lint (`npm run lint:css`) unless explicitly skipped.
5. Commit release artifacts, create the tag, push, and create a GitHub release.

## Script Interface

Use `.agents/skills/theme-github-release/scripts/create_release.sh`:

- `create_release.sh <version>`: full release workflow.
- `--notes-file <path>`: use custom release notes file instead of generated notes.
- `--title <text>`: override release title (default: `comphy-obsidian-theme <version>`).
- `--target <branch>`: set release target branch (default: current branch).
- `--prerelease`: mark the GitHub release as prerelease.
- `--skip-lint`: skip `npm run lint:css`.
- `--dry-run`: print actions only; perform no writes or git operations.
- `--skip-remote-checks`: skip `gh` auth and remote release/tag checks (mainly for local dry-run).

## Operational Rules

- Normalize versions to `X.Y.Z` by removing a leading `v` if provided.
- Abort if local changes exist, unless running `--dry-run`.
- Abort if the tag already exists locally or remotely.
- Require `gh auth status` for real releases.
- Prefer generated notes for normal releases; pass `--notes-file` when user supplies release notes.
