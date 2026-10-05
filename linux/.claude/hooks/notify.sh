#!/bin/sh
# Notification hook: show Claude's notifications as a DMS notification, one per session.
set -eu

event=$(cat)
session=$(printf '%s' "$event" | jq -r '.session_id')
windowfile="${XDG_RUNTIME_DIR:-/tmp}/claude-window-$session"
idfile="${XDG_RUNTIME_DIR:-/tmp}/claude-notification-$session"

# Ghostty is single-instance, so the window can't be found by pid; remember the one focused when the session starts or a prompt is sent.
if [ "$(printf '%s' "$event" | jq -r '.hook_event_name')" != Notification ]; then
    [ -n "${NIRI_SOCKET:-}" ] && niri msg --json focused-window | jq -r '.id // empty' > "$windowfile"
    exit 0
fi

project=$(printf '%s' "$event" | jq -r '.cwd | split("/") | last')
message=$(printf '%s' "$event" | jq -r '.message')
window=$(cat "$windowfile" 2>/dev/null || true)

# Prompts that block Claude stay on screen until handled.
case $(printf '%s' "$event" | jq -r '.notification_type') in
    permission_prompt|worker_permission_prompt|elicitation_dialog|elicitation_url_dialog|agent_needs_input) urgency=critical ;;
    *) urgency=normal ;;
esac

# Reusing the session's notification id replaces its previous one instead of stacking.
id=$(cat "$idfile" 2>/dev/null || echo 0)
set -- -p -r "$id" -u "$urgency" -a "Claude Code" -i claude "Claude Code · $project" "$message"

if [ -z "$window" ]; then
    notify-send "$@" > "$idfile"
    exit 0
fi

# --wait blocks until the notification closes, so run it detached from the hook's timeout.
(
    notify-send --wait -A default=Focus "$@" | {
        read -r id && echo "$id" > "$idfile"
        read -r action && [ "$action" = default ] && niri msg action focus-window --id "$window"
    }
) >/dev/null 2>&1 &
