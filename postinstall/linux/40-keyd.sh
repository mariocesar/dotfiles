#!/bin/sh
# Copied, not linked: keyd runs as root and so does its command(), so root must not read a file the user can write.
set -eu

command -v keyd >/dev/null 2>&1 || { echo "No keyd, skipping"; exit 0; }

src="${XDG_CONFIG_HOME:-$HOME/.config}/keyd/default.conf"
dest=/etc/keyd/default.conf

changed=0
# -L: cmp follows the old link to $src and would call them equal.
if [ -L "$dest" ] || ! cmp -s "$src" "$dest"; then
    sudo install -Dm 644 "$src" "$dest"
    changed=1
fi

# Copied, not linked: systemd loads units before /home is mounted.
dropin="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/system/keyd.service.d/exit-status.conf"
if ! cmp -s "$dropin" /etc/systemd/system/keyd.service.d/exit-status.conf; then
    sudo install -Dm 644 "$dropin" /etc/systemd/system/keyd.service.d/exit-status.conf
    sudo systemctl daemon-reload
fi

if ! systemctl is-enabled --quiet keyd.service || ! systemctl is-active --quiet keyd.service; then
    sudo systemctl enable --now keyd.service
elif [ "$changed" -eq 1 ]; then
    sudo keyd reload
fi
