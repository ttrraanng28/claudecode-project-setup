#!/bin/sh
# Stop hook. Snapshots the worktree to refs/checkpoints/<branch>
# without touching the working branch or index.

set -u

# Find the git repo for the session cwd. If stdin has JSON, use it.
input=$(cat 2>/dev/null || true)
cwd=$(printf '%s' "$input" | jq -r '.cwd // .workspace.current_dir // ""' 2>/dev/null || true)
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null || true

git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# Nothing to snapshot?
if git diff --quiet 2>/dev/null \
   && git diff --cached --quiet 2>/dev/null \
   && [ -z "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
  exit 0
fi

branch=$(git branch --show-current 2>/dev/null)
[ -z "$branch" ] && branch="detached"
ref="refs/checkpoints/$branch"

prev=$(git rev-parse --verify "$ref" 2>/dev/null || true)
head=$(git rev-parse --verify HEAD 2>/dev/null || true)
parent="${prev:-$head}"

# Build a tree from the current worktree using a throwaway index so we never
# touch the user's real index.
tmpidx=$(mktemp -t claude-checkpoint.XXXXXX) || exit 0
trap 'rm -f "$tmpidx"' EXIT

real_index="$(git rev-parse --git-path index)"
[ -f "$real_index" ] && cp "$real_index" "$tmpidx" 2>/dev/null || true

GIT_INDEX_FILE="$tmpidx" git add -A >/dev/null 2>&1 || exit 0
tree=$(GIT_INDEX_FILE="$tmpidx" git write-tree 2>/dev/null) || exit 0

ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
msg="checkpoint: $ts"

if [ -n "$parent" ]; then
  commit=$(printf '%s\n' "$msg" | git commit-tree "$tree" -p "$parent" 2>/dev/null) || exit 0
else
  commit=$(printf '%s\n' "$msg" | git commit-tree "$tree" 2>/dev/null) || exit 0
fi

git update-ref "$ref" "$commit" 2>/dev/null || true
exit 0
