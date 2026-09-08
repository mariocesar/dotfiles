#!/usr/bin/env python3
# Links ~/.config/firefox/{chrome,user.js} into the default Firefox profile.
# The profile dir name is random per machine, so it is resolved from profiles.ini.

import configparser
import os
import sys
from pathlib import Path

HOME = Path.home()
SOURCE = HOME / ".config" / "firefox"
PROFILE_ROOTS = (
    HOME / ".mozilla" / "firefox",
    HOME / "Library" / "Application Support" / "Firefox",
)


def default_profile(root):
    ini = configparser.ConfigParser()
    ini.read(root / "profiles.ini")

    # [Install*] wins; it is what Firefox actually opens. Default=1 is the legacy marker.
    for section in ini.sections():
        if section.startswith("Install") and ini[section].get("Default"):
            return root / ini[section]["Default"]

    for section in ini.sections():
        if ini[section].get("Default") == "1":
            path = Path(ini[section]["Path"])
            return path if ini[section].get("IsRelative") == "0" else root / path

    return None


def link(source, dest):
    if dest.is_symlink() and dest.resolve() == source.resolve():
        print(f"Symlink already points to {source}")
        return

    if dest.is_symlink() or dest.exists():
        backup = dest.with_name(dest.name + ".bak")
        print(f"Moving {dest} to {backup}")
        dest.rename(backup)

    print(f"Linking {source} to {dest}")
    dest.symlink_to(source)


def main():
    roots = [root for root in PROFILE_ROOTS if (root / "profiles.ini").exists()]
    if not roots:
        print("No profiles.ini found, launch Firefox once first")
        return 0

    profile = default_profile(roots[0])
    if not profile or not profile.is_dir():
        print(f"No default profile in {roots[0] / 'profiles.ini'}")
        return 1

    link(SOURCE / "chrome", profile / "chrome")
    link(SOURCE / "user.js", profile / "user.js")
    return 0


if __name__ == "__main__":
    sys.exit(main())
