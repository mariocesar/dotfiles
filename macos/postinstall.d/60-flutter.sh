#!/bin/sh
set -eu

command -v flutter >/dev/null 2>&1 || { echo "No flutter, skipping"; exit 0; }
command -v brew >/dev/null 2>&1 || { echo "No brew, skipping"; exit 0; }

# Studio's bundled JBR is 25 and wins flutter's search order; current Gradle rejects it.
jdk="$(brew --prefix)/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
[ -d "$jdk" ] || { echo "No $jdk, skipping"; exit 0; }

settings="${XDG_CONFIG_HOME:-$HOME/.config}/flutter/settings"
if ! grep -qs "\"jdk-dir\": \"$jdk\"" "$settings"; then
    flutter config --jdk-dir "$jdk" >/dev/null
fi
