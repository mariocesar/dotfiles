#!/bin/sh
# Symlinking a unit into ~/.config/systemd/user does not enable it.
set -eu

command -v systemctl >/dev/null 2>&1 || { echo "No systemctl, skipping"; exit 0; }
dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

units=""
for unit in "$dir"/*.service "$dir"/*.timer; do
    # Only units linked from this repo; other tools write real files here too.
    case "$(readlink -f "$unit")" in "${DOTFILES_ROOT:?}"/*) ;; *) continue ;; esac
    # Only units with [Install] are enabled; the rest are pulled in by those.
    grep -q '^\[Install\]' "$unit" && units="$units $(basename "$unit")"
done
[ -n "$units" ] || exit 0

systemctl --user daemon-reload
# shellcheck disable=SC2086
systemctl --user enable --now $units
