#!/bin/sh
set -eu

# Claude rewrites settings.json, so it can't be a symlink; its hooks are owned by hooks.json instead.
settings=~/.claude/settings.json
hooks=~/.claude/hooks.json
# notify.sh is the notifier; Claude's own channel makes Ghostty show every prompt a second time.
filter='.hooks = $hooks[0] | .preferredNotifChannel = "notifications_disabled"'

[ -f "$settings" ] || echo '{}' > "$settings"

if jq -e --slurpfile hooks "$hooks" "($filter) == ." "$settings" >/dev/null; then
    echo "Claude hooks already match $hooks"
    exit 0
fi

trap 'rm -f "$settings.tmp"' EXIT
echo "Replacing Claude hooks with $hooks"
jq --slurpfile hooks "$hooks" "$filter" "$settings" > "$settings.tmp"
mv "$settings.tmp" "$settings"
