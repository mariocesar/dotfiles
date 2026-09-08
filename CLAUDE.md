# CLAUDE.md

Personal dotfiles (macOS + Linux/niri). No build/lint/test pipeline — verify by symlinking into `$HOME` and using the tool.

## Where to make changes

**Always create and edit config inside this repo, never under `$HOME`.** Everything installed in `$HOME` is a symlink back here, so an edit to a repo file is live immediately — no re-install needed for files that already exist.

- Read and edit via the repo path (`common/.config/ghostty/config`), not `~/.config/ghostty/config`. Both reach the same file, but only the repo path is what git tracks.
- Adding config for a tool that has none yet? Create the file **here**, under the right bucket, at the path it would occupy below `$HOME`: `~/.config/foo/config.toml` → `common/.config/foo/config.toml`. Make the intermediate dirs in the repo; `install.py` creates the matching real dirs under `$HOME`.
- Then run `install.py` so the symlink actually exists, and verify it. A new file is the only case that needs a run.

## Scope of a change

Fix things where their cause lives. A quirk of one file gets a file-local fix — a modeline, a shebang, a `# noqa`. A rule that holds for a class of files belongs in that tool's config. Both directions fail: a global setting added to fix one file changes what was never diagnosed, and the same local patch written twice should have been the config rule.

Breadth needs evidence, not anticipation. Diagnose before widening — including why an existing attempt failed, rather than reaching past it.

## install.py

Symlinks every file in the active buckets to the same relative path under `$HOME`. It walks per-file, so new files and new dirs are picked up automatically.

Everything installable lives in one of three buckets, and where a file sits *is* the declaration of which OS gets it:

```
common/.config/nvim/init.lua           ->  ~/.config/nvim/init.lua        both
linux/.config/niri/config.kdl          ->  ~/.config/niri/config.kdl      Arch only
macos/.local/bin/default-preferences   ->  ~/.local/bin/default-preferences
```

`common/` is installed everywhere; `linux/` and `macos/` add what only that OS can use. Put a file in the wrong bucket and it lands on the wrong machine — but there is no list to forget to update.

Nothing outside a bucket is ever walked, so `install.py`, `README.md`, `ruff.toml` and friends need no exclusion. `DotfileMapper.EXCLUDE_PATTERNS` is down to junk that can appear *inside* a bucket (`.DS_Store`, `*.pyc`, `*~`); `postinstall.d` is skipped structurally, as part of a bucket's shape, not as a denylist entry.

The platform bucket is installed after `common/`, so a path present in both is **deliberately** won by the platform — the run prints `… from common overridden by macos`. That is the supported way to keep a mostly-shared config with one OS-specific variant. Two files of the same name in `linux/` and `macos/` never collide, since only one bucket is ever active: that is how `pkgsync` and `sysupgrade` are one command with two implementations.

Skipping is not unlinking: a file moved between buckets leaves its old symlink behind on the other machine. `--prune` removes those — it unlinks foreign-bucket dests pointing into this repo, including links left dangling by the move, then drops the directories that empties. Left alone: real files, links pointing outside the repo, and anything the active buckets own — a shared-name command like `pkgsync` is installed, not foreign.

Package manifests are config, not repo files: `macos/.config/homebrew/Brewfile` (where `brew bundle --global` looks) and `linux/.config/pkgsync/pkglist*.txt`. They get symlinked like anything else, which is why they need no exclusion. `pkgsync` reads the *installed* copy, so `install.py` has to run before it.

Needs Python 3.10+ (`Path | None` annotations). System `python3` is 3.9 and crashes on import; there is no `python` on `PATH`:

```
python3.13 install.py            # create the symlinks
python3.13 install.py --fake     # dry run — prints what it would link
python3.13 install.py --prune    # also unlink config for the other OS
python3.13 install.py --help     # all options
```

Non-interactive by default: it auto-confirms and links without prompting.

After linking it runs every executable in the active buckets' `postinstall.d/` in name order, so `common/postinstall.d/10-…` precedes `linux/postinstall.d/20-…`. A platform hook with the same name as a common one replaces it, same rule as the links. Hooks are for anything a symlink can't express — resolving a per-machine path, for example. A hook in a platform bucket needs no OS guard; being there is the guard. They must be idempotent, exit non-zero on failure, and are skipped under `--fake`. `.py` hooks run with the same interpreter as `install.py`.

Confirm a new link landed — the arrow must point into `.dotfiles`:

```
ls -l ~/.config/foo/config.toml
# → /Users/<user>/.dotfiles/common/.config/foo/config.toml
```

`Symlink already points to ...` is the steady state for everything installed. `Destination exists` means a real file is sitting where the link should go — it needs `--force` (which moves it aside to `.bak`) or manual removal.

## Comments

Terse. One line, and only when the *why* is not obvious from the line below it — a tradeoff, a footgun, a non-obvious unit. Do not:

- restate what the setting or code already says
- enumerate a tool's option values or explain the ones not chosen — that is `--help`'s job
- write multi-line rationale; that belongs in the commit message

Same for code: no docstring on an obvious function, no narrating the next statement in prose.

## Conventions

- Repo path == home path, under whichever bucket applies. New tool config goes where it'd live under `$HOME`.
- Shell scripts in `*/.local/bin/` start with `set -eu`/`-euo pipefail`. A command needing per-OS behaviour is two files of the same name, one per platform bucket — see `pkgsync`.
- No tests. Sanity-check with `python3.13 install.py --fake`, or reload the tool directly (`source ~/.zshrc`, `:source %`).
