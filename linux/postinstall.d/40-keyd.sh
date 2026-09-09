#!/bin/sh
# keyd runs as root and reads /etc/keyd only; the link targets $HOME, not the repo, so a bucket move can't strand it.
set -eu

command -v keyd >/dev/null 2>&1 || { echo "No keyd, skipping"; exit 0; }

src="${XDG_CONFIG_HOME:-$HOME/.config}/keyd/default.conf"
dest=/etc/keyd/default.conf

if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "$dest is a real file, move it aside first" >&2
    exit 1
fi

relinked=0
if [ "$(readlink "$dest" 2>/dev/null)" != "$src" ]; then
    sudo install -d /etc/keyd
    sudo ln -sfn "$src" "$dest"
    relinked=1
fi

if ! systemctl is-enabled --quiet keyd.service || ! systemctl is-active --quiet keyd.service; then
    sudo systemctl enable --now keyd.service
elif [ "$relinked" -eq 1 ]; then
    sudo keyd reload
fi
