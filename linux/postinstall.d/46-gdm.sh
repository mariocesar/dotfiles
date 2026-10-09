#!/bin/sh
# Copied, not linked: the greeter runs as gdm-greeter and can't read $HOME.
set -eu

command -v gdm >/dev/null 2>&1 || { echo "No gdm, skipping"; exit 0; }

src="${XDG_CONFIG_HOME:-$HOME/.config}/gdm"
changed=0

if ! cmp -s "$src/profile" /etc/dconf/profile/gdm; then
    sudo install -Dm 644 "$src/profile" /etc/dconf/profile/gdm
    changed=1
fi

if ! cmp -s "$src/90-no-suspend" /etc/dconf/db/gdm.d/90-no-suspend; then
    sudo install -Dm 644 "$src/90-no-suspend" /etc/dconf/db/gdm.d/90-no-suspend
    changed=1
fi

if [ "$changed" -eq 1 ]; then
    sudo dconf update
    echo "gdm: the greeter reads this on start; restart gdm (kills a local session) or reboot"
fi
