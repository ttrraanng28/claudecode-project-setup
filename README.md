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
3. Wait for the build (first run installs Claude and configures the firewall)
4. Verify: `claude --version`
5. Run Claude in autonomous mode: `claude --dangerously-skip-permissions`

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
