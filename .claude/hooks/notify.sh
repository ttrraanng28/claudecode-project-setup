#!/bin/sh
# Stop hook. Sends a session-end notification.
# - Always rings the terminal bell.
# - If CLAUDE_NTFY_TOPIC is set, also posts to ntfy.sh for phone/desktop alerts.

set -u

printf '\a'

if [ -n "${CLAUDE_NTFY_TOPIC:-}" ]; then
  curl -s --max-time 5 \
    -d "Claude session finished" \
    -H "Title: Claude Code" \
    -H "Priority: default" \
    "https://ntfy.sh/${CLAUDE_NTFY_TOPIC}" >/dev/null 2>&1 || true
fi

exit 0
