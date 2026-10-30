#!/bin/sh
# niri rejects config.kdl until dms/windowrules.kdl exists, and DMS only writes it once the shell is running.
set -eu

dir="${XDG_CONFIG_HOME:-$HOME/.config}/niri/dms"
mkdir -p "$dir"
[ -e "$dir/windowrules.kdl" ] || : > "$dir/windowrules.kdl"
