#!/bin/sh
# PreToolUse hook for Bash. Runs even under --dangerously-skip-permissions.
# Blocks with exit 2 and a reason on stderr so Claude sees it.

set -u

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

block() {
  printf 'blocked by block-destructive-bash: %s\n' "$1" >&2
  exit 2
}

# Literal substring matches (cheap, clearest first).
case "$cmd" in
  *"rm -rf /"*)         block "rm -rf of root" ;;
  *"rm -rf ~"*)         block "rm -rf of home" ;;
  *'rm -rf $HOME'*)     block "rm -rf \$HOME" ;;
  *'rm -rf ${HOME'*)    block "rm -rf \${HOME...}" ;;
esac

# Regex matches via grep -E.
matches() { printf '%s' "$cmd" | grep -Eq "$1"; }

matches '(^|[[:space:]])sudo([[:space:]]|$)' && block "sudo usage"

if matches 'git[[:space:]]+push[[:space:]]+.*--force([^-]|$)' && ! matches 'force-with-lease'; then
  block "git push --force (use --force-with-lease instead)"
fi

matches 'git[[:space:]]+reset[[:space:]]+--hard'                   && block "git reset --hard"
matches 'git[[:space:]]+clean[[:space:]]+-[fF][dD]?'               && block "git clean -fd"
matches 'git[[:space:]]+checkout[[:space:]]+--([[:space:]]|$)'     && block "git checkout -- (discards work)"
matches 'curl[^|]*\|[[:space:]]*(sh|bash)'                         && block "curl | sh / bash pipe"
matches 'wget[^|]*\|[[:space:]]*(sh|bash)'                         && block "wget | sh / bash pipe"
matches '(^|[[:space:]])>[[:space:]]*\.env([[:space:]]|$|\.)'      && block "redirect into .env"
matches '(^|[[:space:]])\.ssh/'                                    && block "touching .ssh/"

exit 0
