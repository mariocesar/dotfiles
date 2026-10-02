#!/bin/sh
# Notification hook: show Claude's permission prompts and idle waits as a macOS notification.
set -eu

event=$(cat)
# Also registered on UserPromptSubmit for the Linux window tracking; nothing to do here.
[ "$(printf '%s' "$event" | jq -r '.hook_event_name')" = Notification ] || exit 0
project=$(printf '%s' "$event" | jq -r '.cwd | split("/") | last')
message=$(printf '%s' "$event" | jq -r '.message')
title="Claude Code · $project"

# Hooks run without a controlling tty; Claude's is found up the process tree.
tty=
pid=$PPID
while [ "$pid" -gt 1 ]; do
    tty=$(ps -o tty= -p "$pid" | tr -d ' ')
    [ "$tty" != '??' ] && break
    tty=
    pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
done

# Ghostty posts it under its own signed bundle, and a click focuses the exact tab and split that raised it.
if [ "${TERM_PROGRAM:-}" = ghostty ] && [ -n "$tty" ] && [ -w "/dev/$tty" ]; then
    # Control chars would end the OSC early; ';' separates its fields.
    printf '\033]777;notify;%s;%s\007' \
        "$(printf '%s' "$title" | tr -d '\000-\037;')" \
        "$(printf '%s' "$message" | tr -d '\000-\037')" > "/dev/$tty"
    exit 0
fi

# Pass text as argv so quotes in the message can't break the AppleScript.
osascript -e 'on run argv' -e 'display notification (item 2 of argv) with title (item 1 of argv)' -e 'end run' \
    "$title" "$message"
