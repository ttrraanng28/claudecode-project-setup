# Project Setup

This project inherits all global preferences from `~/.claude/CLAUDE.md`. Override or extend below as needed.

## Project-Specific Stack

- Language: [e.g. TypeScript]
- Framework: [e.g. Next.js 15 App Router]
- Package manager: [e.g. npm]
- Testing: [e.g. vitest]
- Linting: [e.g. biome]

## Browser QA Protocol

**Applies when:** browser-testing or UI verification via Playwright.

- Act as a senior full-stack engineer. Navigate methodically, read console errors, inspect snapshots.
- **Never skip, suppress, or retry-loop past errors.** Every error is a signal — trace it to source.
- **Small/medium fixes** (wrong routes, missing props, styling, null checks): fix immediately, re-test.
- **Major fixes** (architecture, migrations, >3 files): present findings and proposed fix first.

## Project Overrides

Add any project-specific rules here that override global guidelines (e.g., style, tooling, workflow). Leave empty if none.

## Environment

This project runs inside a secure devcontainer.

To activate:
- Open folder in Cursor
- Cmd+Shift+P → "Dev Containers: Reopen in Container"
- Wait for build to complete
- Verify with: `claude --version`

To run Claude Code in bypass mode, use the wrapper:
```
bin/claude-yolo
```

## Guardrails

Project-versioned hooks at `.claude/hooks/` (installed into the container by
`post-create.sh`) run even under `--dangerously-skip-permissions`:

- Destructive Bash (`rm -rf ~`, `sudo`, `git push --force` without `--force-with-lease`, `git reset --hard`, `curl | sh`, writes to `.env`/`.ssh`) is blocked.
- Edits and writes are confined to `/workspace` inside the container. `~/.ssh`, `~/.aws`, and `~/.claude/settings*.json` are always blocked.
- Every turn end auto-snapshots to `refs/checkpoints/<branch>` — working branch is never touched. Recover with `git diff refs/checkpoints/<branch>` or `git checkout refs/checkpoints/<branch> -- <path>`.

A tool call that exits 2 with a `blocked by ...` message is the guard firing — adjust your approach rather than retrying.
