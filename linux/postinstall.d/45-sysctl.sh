#!/bin/sh
# Copied, not linked: systemd-sysctl runs before /home is mounted.
set -eu

src="${XDG_CONFIG_HOME:-$HOME/.config}/sysctl.d/99-local.conf"
dest=/etc/sysctl.d/99-local.conf

if ! cmp -s "$src" "$dest"; then
    sudo install -m 644 "$src" "$dest"
    sudo sysctl --system >/dev/null
fi
