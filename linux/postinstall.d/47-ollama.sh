#!/bin/sh
# Copied, not linked: systemd loads units before /home is mounted.
set -eu

command -v ollama >/dev/null 2>&1 || { echo "No ollama, skipping"; exit 0; }

src="${XDG_CONFIG_HOME:-$HOME/.config}/ollama.service.d/local.conf"
dest=/etc/systemd/system/ollama.service.d/local.conf

if ! cmp -s "$src" "$dest"; then
    sudo install -D -m 644 "$src" "$dest"
    sudo systemctl daemon-reload
    sudo systemctl try-restart ollama.service
fi
