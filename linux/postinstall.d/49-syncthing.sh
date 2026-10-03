#!/bin/sh
# The package ships the user unit; 20-systemd-user.sh only enables units kept in the repo.
set -eu

command -v syncthing >/dev/null 2>&1 || { echo "No syncthing, skipping"; exit 0; }

systemctl --user enable --now syncthing.service
