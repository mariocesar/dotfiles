#!/bin/sh
# Notification hook: show Claude's permission prompts and idle waits as a DMS notification.
set -eu

event=$(cat)
session=$(printf '%s' "$event" | jq -r '.session_id')
windowfile="${XDG_RUNTIME_DIR:-/tmp}/claude-window-$session"

# Ghostty is single-instance, so the window can't be found by pid; remember the one focused when the prompt is sent.
if [ "$(printf '%s' "$event" | jq -r '.hook_event_name')" = UserPromptSubmit ]; then
    [ -n "${NIRI_SOCKET:-}" ] && niri msg --json focused-window | jq -r '.id // empty' > "$windowfile"
    exit 0
fi

project=$(printf '%s' "$event" | jq -r '.cwd | split("/") | last')
message=$(printf '%s' "$event" | jq -r '.message')
window=$(cat "$windowfile" 2>/dev/null || true)

if [ -z "$window" ]; then
    notify-send -a "Claude Code" -i claude "Claude Code · $project" "$message"
    exit 0
fi

# --wait blocks until the notification closes, so run it detached from the hook's timeout.
(
    action=$(notify-send --wait -A default=Focus -a "Claude Code" -i claude "Claude Code · $project" "$message")
    [ "$action" = default ] && niri msg action focus-window --id "$window"
) >/dev/null 2>&1 &
