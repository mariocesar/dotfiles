# Scripts

Conventions for commands in `home/*/.local/bin/`. Which bucket a script goes in is in `CLAUDE.md`; how its Python is written is in `docs/python.md`.

## Names

- One English word for one job, reading as a sentence with its arguments: `share ~/Downloads`, `ask "…"`, `agenda`.
- More than one word: verb first, hyphenated: `update-preferences`, `setup-snapshot`.
- A helper for one tool leads with that tool's name: `git-watch` (runs as `git watch`), `nvim-pipe`, `tmux-log`.
- Check for collisions before creating the file: `command -v <name>`, and `pacman -F usr/bin/<name>` on Arch. Avoid near-twins of existing scripts: `browse` next to `browser` reads as "open the browser".

## Header

- Line 2 is one sentence saying what the script does: `# Print the current USDT price of …`. `uses/uses.py` publishes it on the /uses page, and skips a script without it.
- In a uv script the sentence still goes on line 2, above `# /// script`.

## Language

- Shell starts with `set -eu`, or `set -euo pipefail` when a failure inside a pipe matters. Helper functions read as English: `command_exists`, `load_if_exists`.
- Python with only the stdlib: `#!/usr/bin/env python3`.
- Python with dependencies: a uv inline script, `#!/usr/bin/env -S uv run --quiet --script` plus a `# /// script` block. No venv, no requirements file.

## Behavior

- A uv script that serves a page carries its HTML, CSS and JS inside, so it stays one file. The page follows `docs/ui.md`.
- Ctrl+C exits quietly, without a traceback.
