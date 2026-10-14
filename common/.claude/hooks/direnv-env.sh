#!/bin/sh
# Load the direnv env of Claude's cwd into the Bash tool, like the zsh prompt hook does.
[ -n "${CLAUDE_ENV_FILE:-}" ] || exit 0

command -v direnv >/dev/null || exit 0

dir=$(jq -r '.new_cwd // .cwd')

msg=$(cd "$dir" && direnv export bash 2>&1 >> "$CLAUDE_ENV_FILE" | tail -n 1 | sed "s/$(printf '\033')\[[0-9;]*m//g")

[ -z "$msg" ] || jq -n --arg m "$msg" '{systemMessage: $m}'
