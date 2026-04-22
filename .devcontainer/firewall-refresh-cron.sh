#!/usr/bin/env bash
# Installs a cron entry that re-resolves the firewall allowlist every 2 hours,
# so CDN IP rotations (npm, Anthropic, GitHub, etc.) don't silently break the
# container. Must be run as root.
#
# Usage: firewall-refresh-cron.sh install

set -euo pipefail

CMD="${1:-install}"
CRON_LINE='0 */2 * * * /usr/local/bin/init-firewall.sh refresh >> /var/log/firewall-refresh.log 2>&1'
LOG=/var/log/firewall-refresh.log

case "$CMD" in
  install)
    touch "$LOG"
    chmod 644 "$LOG"

    # Replace any existing line for this script, then append fresh.
    ( crontab -l 2>/dev/null | grep -v 'init-firewall.sh[[:space:]]\+refresh' ; echo "$CRON_LINE" ) \
      | crontab -

    # node:20 images ship cron but don't start it. Start the daemon if not running.
    if ! pgrep -x cron >/dev/null 2>&1; then
      service cron start >/dev/null 2>&1 || cron
    fi

    echo "firewall-refresh-cron: installed (every 2h, log=$LOG)"
    ;;
  uninstall)
    crontab -l 2>/dev/null | grep -v 'init-firewall.sh[[:space:]]\+refresh' | crontab - || true
    echo "firewall-refresh-cron: uninstalled"
    ;;
  *)
    echo "usage: $0 {install|uninstall}" >&2
    exit 2
    ;;
esac
