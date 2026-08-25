# CLAUDE.md

Personal dotfiles (macOS + Linux/niri). No build/lint/test pipeline — verify by symlinking into `$HOME` and using the tool.

## Where to make changes

**Always create and edit config inside this repo, never under `$HOME`.** Everything installed in `$HOME` is a symlink back here, so an edit to a repo file is live immediately — no re-install needed for files that already exist.

- Read and edit via the repo path (`.config/ghostty/config`), not `~/.config/ghostty/config`. Both reach the same file, but only the repo path is what git tracks.
- Adding config for a tool that has none yet? Create the file **here**, at the path it would occupy under `$HOME`: `~/.config/foo/config.toml` → `.config/foo/config.toml`. Make the intermediate dirs in the repo; `install.py` creates the matching real dirs under `$HOME`.
- Then run `install.py` so the symlink actually exists, and verify it. A new file is the only case that needs a run.

## install.py

Symlinks every non-excluded file to the same relative path under `$HOME` (`.config/nvim/init.lua` → `~/.config/nvim/init.lua`). It walks per-file, so new files and new dirs are picked up automatically. Exclusions live in `DotfileMapper.EXCLUDE_PATTERNS`; add repo-management files there, not new config.

Needs Python 3.10+ (`Path | None` annotations). System `python3` is 3.9 and crashes on import; there is no `python` on `PATH`:

```
python3.13 install.py            # create the symlinks
python3.13 install.py --fake     # dry run — prints what it would link
python3.13 install.py --help     # all options
```

Non-interactive by default: it auto-confirms and links without prompting.

Confirm a new link landed — the arrow must point into `.dotfiles`:

```
ls -l ~/.config/foo/config.toml
# → /Users/<user>/.dotfiles/.config/foo/config.toml
```

`Symlink already points to ...` is the steady state for everything installed. `Destination exists` means a real file is sitting where the link should go — it needs `--force` (which moves it aside to `.bak`) or manual removal.

## Comments

Terse. One line, and only when the *why* is not obvious from the line below it — a tradeoff, a footgun, a non-obvious unit. Do not:

- restate what the setting or code already says
- enumerate a tool's option values or explain the ones not chosen — that is `--help`'s job
- write multi-line rationale; that belongs in the commit message

Same for code: no docstring on an obvious function, no narrating the next statement in prose.

## Conventions

- Repo path == home path, always. New tool config goes where it'd live under `$HOME`.
- Shell scripts in `.local/bin/` start with `set -eu`/`-euo pipefail`.
- No tests. Sanity-check with `python3.13 install.py --fake`, or reload the tool directly (`source ~/.zshrc`, `:source %`).
