#!/bin/sh
# The portal serves GTK its settings from dconf, and a binary dconf db can't be symlinked.
set -eu

command -v gsettings >/dev/null 2>&1 || { echo "No gsettings, skipping"; exit 0; }

# GNOME's schema default is false; without this middle-click paste is dead in every GTK app.
gsettings set org.gnome.desktop.interface gtk-enable-primary-paste true
