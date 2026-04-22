#!/bin/sh
# PreToolUse hook for Edit and Write. Runs even under --dangerously-skip-permissions.
# Inside the devcontainer: only allow /workspace/** writes.
# Outside the container: allow normal writes, but block credential stores and
# self-loosening of ~/.claude/settings*.json.

set -u

input=$(cat)
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')

block() {
  printf 'blocked by restrict-edit-paths: %s\n' "$1" >&2
  exit 2
}

# Always-block: credential stores, regardless of environment.
case "$path" in
  */.ssh/*|*/.aws/*|*/.gnupg/*) block "refusing to write to credential directory ($path)" ;;
esac

# Block writes to the user's global Claude settings to prevent Claude from
# silently loosening its own guardrails. Project-scoped settings under
# /workspace/.claude/ are allowed.
case "$path" in
  "$HOME"/.claude/settings*.json|"$HOME"/.claude/hooks/*)
    block "refusing to modify global Claude settings or hooks"
    ;;
esac

# Inside container: confine writes to /workspace.
if [ "${DEVCONTAINER:-}" = "true" ]; then
  case "$path" in
    /workspace/*) exit 0 ;;
    *)            block "Edit/Write outside /workspace ($path)" ;;
  esac
fi

exit 0
