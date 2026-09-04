#!/bin/sh
# Symlinking a unit into ~/.config/systemd/user does not enable it.
set -eu

command -v systemctl >/dev/null 2>&1 || { echo "No systemctl, skipping"; exit 0; }
root=${DOTFILES_ROOT:-$(dirname "$0")/..}

units=""
for unit in "$root"/.config/systemd/user/*.service "$root"/.config/systemd/user/*.timer; do
    [ -f "$unit" ] || continue
    # Only units with [Install] are enabled; the rest are pulled in by those.
    grep -q '^\[Install\]' "$unit" && units="$units $(basename "$unit")"
done
[ -n "$units" ] || exit 0

systemctl --user daemon-reload
# shellcheck disable=SC2086
systemctl --user enable --now $units
