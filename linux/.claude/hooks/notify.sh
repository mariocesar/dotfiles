#!/bin/sh
# Notification hook: show Claude's permission prompts and idle waits as a DMS notification.
set -eu

event=$(cat)
project=$(printf '%s' "$event" | jq -r '.cwd | split("/") | last')
message=$(printf '%s' "$event" | jq -r '.message')

notify-send -a "Claude Code" -i claude "Claude Code · $project" "$message"
