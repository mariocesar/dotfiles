---
name: apply
description: Apply the dotfiles to this machine. Dry-run install.py, show what would change, apply only after confirmation, then validate the niri config.
---

1. From the repo root run `python3.13 install.py --fake` and summarize what would change
   (links created, files overwritten or removed, postinstall hooks that would run). Summary only, no raw output.
2. If anything would be overwritten or removed, list it and stop. Ask before continuing.
3. On confirmation run `python3.13 install.py --force`.
4. If any file under `linux/.config/niri/` changed, run
   `niri validate -c linux/.config/niri/config.kdl`. If it fails, show the error and fix the config before finishing.
5. Report what was applied in three lines or fewer.
