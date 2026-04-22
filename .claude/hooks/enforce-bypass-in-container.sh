#!/bin/sh
# SessionStart hook. Refuses --dangerously-skip-permissions outside a devcontainer
# by aborting the session via JSON output.

set -u

# Inside container: always allow.
if [ "${DEVCONTAINER:-}" = "true" ]; then
  exit 0
fi

# Detect whether Claude was launched with --dangerously-skip-permissions.
# Walk up the process tree from this hook's parent looking for the flag in argv.
detect_bypass() {
  pid="${PPID:-0}"
  hops=0
  while [ "$pid" -gt 1 ] && [ "$hops" -lt 8 ]; do
    cmd=$(ps -o command= -p "$pid" 2>/dev/null || true)
    case "$cmd" in
      *--dangerously-skip-permissions*) return 0 ;;
    esac
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ' || echo 0)
    hops=$((hops + 1))
  done
  return 1
}

if detect_bypass; then
  printf '{"continue": false, "stopReason": "Bypass mode (--dangerously-skip-permissions) is only allowed inside the devcontainer. Rerun inside the container, or export DEVCONTAINER=true if you know what you are doing."}\n'
fi

exit 0
