#!/bin/sh
# Notification hook: show Claude's permission prompts and idle waits as a macOS notification.
set -eu

event=$(cat)
# Also registered on UserPromptSubmit for the Linux window tracking; nothing to do here.
[ "$(printf '%s' "$event" | jq -r '.hook_event_name')" = Notification ] || exit 0
project=$(printf '%s' "$event" | jq -r '.cwd | split("/") | last')
message=$(printf '%s' "$event" | jq -r '.message')

# Pass text as argv so quotes in the message can't break the AppleScript.
osascript -e 'on run argv' -e 'display notification (item 2 of argv) with title (item 1 of argv)' -e 'end run' \
    "Claude Code · $project" "$message"
