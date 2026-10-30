#!/bin/sh
# Copied, not linked: systemd-sysctl runs before /home is mounted.
set -eu

src="${XDG_CONFIG_HOME:-$HOME/.config}/sysctl.d/99-local.conf"
dest=/etc/sysctl.d/99-local.conf

if ! cmp -s "$src" "$dest"; then
    # Apply before copying, so a failed apply leaves a diff and the next run retries.
    sudo sysctl -p "$src" >/dev/null
    sudo install -m 644 "$src" "$dest"
fi
