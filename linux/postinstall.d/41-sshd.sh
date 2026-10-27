#!/bin/sh
# Copied, not linked: sshd starts before /home is mounted.
set -eu

command -v sshd >/dev/null 2>&1 || { echo "No sshd, skipping"; exit 0; }
command -v tailscale >/dev/null 2>&1 || { echo "No tailscale, skipping"; exit 0; }

src="${XDG_CONFIG_HOME:-$HOME/.config}/ssh/sshd_config.d/10-local.conf"
dest=/etc/ssh/sshd_config.d/10-local.conf

if ! cmp -s "$src" "$dest"; then
    sudo install -m 644 "$src" "$dest"
    # sshd re-execs on reload, so a broken file would take it down; back it out instead.
    sudo sshd -t || { sudo rm "$dest"; exit 1; }
    if systemctl is-active --quiet sshd.service; then
        sudo systemctl reload sshd.service
    fi
fi
