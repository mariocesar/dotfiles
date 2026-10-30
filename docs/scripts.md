# Scripts

Conventions for commands in `*/.local/bin/`. Which bucket a script goes in is in `CLAUDE.md`.

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
- Python passes `ruff check` and `ruff format` (repo `ruff.toml`) when written or edited. A deliberate pattern gets a one-line `# noqa: CODE` on its line. Older scripts are fixed when touched for another reason.

## Code shape

- Code reads top to bottom in the order a reader meets it: output order in a printer, a request's path in a server. Don't group by type, with every constant first and every function after.
- A constant sits beside its one user. Only policy goes first, such as what `share` never serves.
- Helpers are vocabulary: one-line words used many times that make the body read like its output (`h2`, `tr`, `code`, `>> stdout` in `uses.py`). A function with one caller is inlined, unless it is a boundary worth naming, such as a security check.
- A printer, which reads files and writes text for a pipe, can be plain top-level code like `uses.py`.
- A service keeps a `main()` whose stages read bootstrap, prepare, config, run, each marked by a one-line comment. The settings its handlers read are assigned there under one `global … # noqa: PLW0603`, with no placeholder values at module level. A long staged `main()` takes `# noqa: C901, PLR0915` rather than single-use stage functions.
- Trust the repo's own files: a traceback is the error message. Never trust what arrives over the network: there every check stays.
- A uv script that serves a page carries its HTML, CSS and JS inside, so it stays one file. The page follows `docs/web-ui.md`.
- Ctrl+C exits quietly, without a traceback.
