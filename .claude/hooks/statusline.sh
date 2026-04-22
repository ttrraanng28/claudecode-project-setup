#!/bin/sh
# Status line. Shows cwd | branch | model, plus [BYPASS] in red when
# --dangerously-skip-permissions is active somewhere in Claude's process tree.

set -u

input=$(cat)
cwd=$(printf '%s'   "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(printf '%s' "$input" | jq -r '.model.display_name // "?"')

basename=$(basename "${cwd:-?}")
branch=$(git -C "${cwd:-.}" branch --show-current 2>/dev/null)
[ -z "$branch" ] && branch="-"

bypass=""
if pgrep -fa -- '--dangerously-skip-permissions' >/dev/null 2>&1; then
  # ANSI red + bold
  bypass=" $(printf '\033[1;31m[BYPASS]\033[0m')"
fi

printf '%s | %s | %s%s' "$basename" "$branch" "$model" "$bypass"
