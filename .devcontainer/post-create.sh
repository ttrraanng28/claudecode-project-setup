#!/usr/bin/env bash
# Runs once after the container is first created. Installs:
#   - the guardrail hooks into /home/node/.claude/hooks/
#   - a merged /home/node/.claude/settings.json that registers them
#   - project deps for whichever stacks this workspace uses
#
# Re-run manually to pick up hook updates without a full container rebuild.

set -euo pipefail
cd /workspace

CLAUDE_DIR="${HOME}/.claude"
HOOKS_SRC="/workspace/.claude/hooks"
HOOKS_DST="${CLAUDE_DIR}/hooks"
SETTINGS="${CLAUDE_DIR}/settings.json"

# -- 1. Install hook scripts --------------------------------------------------
if [ -d "$HOOKS_SRC" ]; then
  mkdir -p "$HOOKS_DST"
  echo "post-create: installing hooks -> $HOOKS_DST"
  for f in "$HOOKS_SRC"/*.sh; do
    [ -f "$f" ] || continue
    install -m 0755 "$f" "$HOOKS_DST/$(basename "$f")"
  done
else
  echo "post-create: no .claude/hooks/ in workspace; skipping hook install"
fi

# -- 2. Merge hook + statusLine config into container settings.json -----------
mkdir -p "$CLAUDE_DIR"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

PATCH=$(cat <<'JSON'
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/hooks/statusline.sh"
  },
  "hooks": {
    "SessionStart": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/enforce-bypass-in-container.sh" }] }
    ],
    "PreToolUse": [
      { "matcher": "Bash",       "hooks": [{ "type": "command", "command": "~/.claude/hooks/block-destructive-bash.sh" }] },
      { "matcher": "Edit|Write", "hooks": [{ "type": "command", "command": "~/.claude/hooks/restrict-edit-paths.sh" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/checkpoint.sh" }] }
    ]
  }
}
JSON
)

# Recursive merge: patch wins for scalars, hooks/statusLine blocks replace
# whatever was there so we don't double-register.
jq -s '.[0] * .[1]' "$SETTINGS" <(printf '%s' "$PATCH") > "${SETTINGS}.new"
mv "${SETTINGS}.new" "$SETTINGS"
echo "post-create: merged hooks + statusLine into $SETTINGS"

# -- 3. Project deps ----------------------------------------------------------
if [ -f package-lock.json ]; then
  echo "post-create: npm ci"
  npm ci
elif [ -f package.json ]; then
  echo "post-create: npm install"
  npm install
fi

if [ -f pyproject.toml ]; then
  echo "post-create: uv sync"
  uv sync || true
elif [ -f requirements.txt ]; then
  echo "post-create: pip install -r requirements.txt"
  python3 -m pip install --user -r requirements.txt
fi

echo "post-create: done"
