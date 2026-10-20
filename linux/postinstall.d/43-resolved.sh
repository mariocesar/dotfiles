#!/bin/sh
# Copied, not linked: systemd-resolved starts before /home is mounted.
set -eu

systemctl is-enabled --quiet systemd-resolved.service || { echo "No systemd-resolved, skipping"; exit 0; }

src="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/resolved.conf.d/99-local.conf"
dest=/etc/systemd/resolved.conf.d/99-local.conf

if ! cmp -s "$src" "$dest"; then
    sudo install -D -m 644 "$src" "$dest"
    sudo systemctl restart systemd-resolved.service
fi
