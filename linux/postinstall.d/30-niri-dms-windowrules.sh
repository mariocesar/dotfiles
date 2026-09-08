#!/bin/sh
# niri rejects config.kdl until dms/windowrules.kdl exists; DMS only creates it with the first rule.
set -eu

dir="${XDG_CONFIG_HOME:-$HOME/.config}/niri/dms"
mkdir -p "$dir"
[ -e "$dir/windowrules.kdl" ] || : > "$dir/windowrules.kdl"
