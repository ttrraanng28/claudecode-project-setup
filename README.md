# Claude Code Setup

A project template for AI-assisted development with Claude Code — user preferences, a docs-driven context system, and custom workflow commands.

## What this repo contains

- `.claude/commands/`: reusable slash commands
- `.claude/docs/`: on-demand project docs
- `CLAUDE.md`: agent-facing project rules and behavior
- `HANDOFF.md`: short running context between sessions

## Quick start

```bash
git clone https://github.com/YOUR_USERNAME/my-claude-setup.git my-project
cd my-project
```

Or copy `.claude/`, `CLAUDE.md`, and `HANDOFF.md` into an existing project.

## Sandbox Setup

Prerequisites: Docker Desktop and the Dev Containers extension in Cursor.

1. Click **Use this template** on GitHub → clone to your machine
2. Open in Cursor → `Cmd+Shift+P` → **Dev Containers: Reopen in Container**
3. Wait for the build (first run installs Claude and runs `post-create.sh` to install hooks and project deps)
4. Verify: `claude --version`
5. Run Claude in autonomous mode: `bin/claude-yolo`

`claude-yolo` is a thin wrapper that starts `claude --dangerously-skip-permissions`
and refuses to run outside the devcontainer. Set `CLAUDE_BYPASS_HOST_OK=1` to
override, but don't — see the guardrails below for why.

## Guardrails under bypass mode

Running `--dangerously-skip-permissions` disables permission prompts, so the
`deny` rules in `.claude/settings.local.json` are **not** enforced. Real
enforcement lives in hooks shipped with this repo at `.claude/hooks/`.

The container's `post-create.sh` installs them into `/home/node/.claude/hooks/`
and merges the hook wiring into the container's `settings.json` on first boot.
To pick up hook edits without a full rebuild, re-run `.devcontainer/post-create.sh`
inside the container.

For Claude runs **outside** the container, copy the scripts to your host's
`~/.claude/hooks/` once:
```
mkdir -p ~/.claude/hooks && cp .claude/hooks/*.sh ~/.claude/hooks/
```
and add the `hooks` + `statusLine` block from `.devcontainer/post-create.sh`
to your `~/.claude/settings.json`.

The hooks:

- `enforce-bypass-in-container.sh` (SessionStart) — refuses bypass outside the container
- `block-destructive-bash.sh` (PreToolUse/Bash) — blocks `rm -rf ~`, `sudo`, `git push --force` (without `--force-with-lease`), `git reset --hard`, `curl | sh`, writes to `.env` / `.ssh`
- `restrict-edit-paths.sh` (PreToolUse/Edit|Write) — confines writes to `/workspace` inside the container; always blocks `~/.ssh`, `~/.aws`, and self-loosening of `~/.claude/settings*.json`
- `checkpoint.sh` (Stop) — snapshots the worktree to `refs/checkpoints/<branch>` so you can roll back without touching your working branch

## New project checklist

After cloning, configure the template for your project:

- [ ] Fill in `CLAUDE.md` → `## Project-Specific Stack` with your actual stack
- [ ] Update `.claude/docs/index.md` → replace placeholder paths with your real file paths
- [ ] Fill in `.claude/docs/architecture.md` with your stack and project structure
- [ ] Delete doc stubs you won't use (`api.md`, `database.md`, `deployment.md`) or fill them in
- [ ] Clear `HANDOFF.md` and write a 1-2 sentence project summary
- [ ] Update `.claude/settings.local.json` → change `Edit`/`Write` paths from `/workspace/**` to your project root

## How it works

### `CLAUDE.md`
Fill in the `[placeholders]` with your stack, tools, and name. This is loaded every session — keep it lean.

### Docs system (`.claude/docs/`)
Project knowledge loaded **on demand**. Claude reads `index.md` first, then pulls only the relevant file for the task at hand.

**What belongs here:** architecture decisions, DB schema, API patterns, deployment steps, domain-specific conventions — anything too detailed for `CLAUDE.md` but needed for specific tasks.

**What doesn't belong here:** command references, skill docs, or anything Claude already knows.

Add a doc, add a row to `index.md`. That's the whole system.

### `HANDOFF.md`
Append a 1-2 sentence summary after each feature. Claude reads it at session start to recover context without re-reading the whole codebase.

### Commands

| Command | Purpose |
|---------|---------|
| `/commit` | Review changes and create a semantic commit |
| `/add <name> <desc>` | Generate a new custom slash command |
| `/note <text>` | Capture a note to `~/.claude/my_vault/` |
| `/educate <concept>` | 6-phase Socratic lesson saved as `lesson-<topic>.md` |
