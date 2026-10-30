#!/bin/sh
set -eu

command -v flutter >/dev/null 2>&1 || { echo "No flutter, skipping"; exit 0; }

# Arch's default JDK is 26 and Studio's bundled JBR 25; current Gradle accepts neither.
jdk=/usr/lib/jvm/java-21-openjdk
[ -d "$jdk" ] || { echo "No $jdk, skipping"; exit 0; }

settings="${XDG_CONFIG_HOME:-$HOME/.config}/flutter/settings"
if ! grep -qs "\"jdk-dir\": \"$jdk\"" "$settings"; then
    flutter config --jdk-dir "$jdk" >/dev/null
fi
