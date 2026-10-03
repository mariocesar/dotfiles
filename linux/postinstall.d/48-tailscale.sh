#!/bin/sh
# Only the daemon; logging in is interactive, so `sudo tailscale up` stays manual.
set -eu

command -v tailscale >/dev/null 2>&1 || { echo "No tailscale, skipping"; exit 0; }

if ! systemctl is-enabled --quiet tailscaled.service || ! systemctl is-active --quiet tailscaled.service; then
    sudo systemctl enable --now tailscaled.service
fi

# The systray's connect toggle runs as $USER; without operator it gets access denied.
if [ "$(tailscale debug prefs | jq -r .OperatorUser)" != "$USER" ]; then
    sudo tailscale set --operator="$USER"
fi
