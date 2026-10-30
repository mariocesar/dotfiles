#!/bin/sh
# Copied, not linked: polkitd runs with ProtectHome. rules.d is 0750 root:polkitd, so even the compare needs sudo.
set -eu

src="${XDG_CONFIG_HOME:-$HOME/.config}/polkit-1/rules.d/50-inhibit-sleep.rules"
dest=/etc/polkit-1/rules.d/50-inhibit-sleep.rules

if ! sudo cmp -s "$src" "$dest"; then
    sudo install -m 644 "$src" "$dest"
fi
