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
