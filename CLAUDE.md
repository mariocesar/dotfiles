# CLAUDE.md

Personal dotfiles (macOS + Linux/niri). No build/lint/test pipeline — verify by symlinking into `$HOME` and using the tool.

## Where to make changes

**Always create and edit config inside this repo, never under `$HOME`.** Everything installed in `$HOME` is a symlink back here, so an edit to a repo file is live immediately — no re-install needed for files that already exist.

- Read and edit via the repo path (`home/common/.config/ghostty/config`), not `~/.config/ghostty/config`. Both reach the same file, but only the repo path is what git tracks.
- Adding config for a tool that has none yet? Create the file **here**, under the right bucket, at the path it would occupy below `$HOME`: `~/.config/foo/config.toml` → `home/common/.config/foo/config.toml`. Make the intermediate dirs in the repo; `install.py` creates the matching real dirs under `$HOME`.
- Then run `install.py` so the symlink actually exists, and verify it. A new file is the only case that needs a run.

## Scope of a change

Fix things where their cause lives. A quirk of one file gets a file-local fix — a modeline, a shebang, a `# noqa`. A rule that holds for a class of files belongs in that tool's config. Both directions fail: a global setting added to fix one file changes what was never diagnosed, and the same local patch written twice should have been the config rule.

Breadth needs evidence, not anticipation. Diagnose before widening — including why an existing attempt failed, rather than reaching past it.

## install.py

Symlinks every file in the active buckets to the same relative path under `$HOME`. It walks per-file, so new files and new dirs are picked up automatically.

Everything installable lives in one of three buckets under `home/`, and where a file sits *is* the declaration of which OS gets it:

```
home/common/.config/nvim/init.lua         ->  ~/.config/nvim/init.lua        both
home/linux/.config/niri/config.kdl        ->  ~/.config/niri/config.kdl      Arch only
home/macos/.local/bin/update-preferences  ->  ~/.local/bin/update-preferences
```

`common/` is installed everywhere; `linux/` and `macos/` add what only that OS can use. Put a file in the wrong bucket and it lands on the wrong machine — but there is no list to forget to update.

`home/` holds only what gets installed; the rest of the root is the project around it (`install.py`, `postinstall/`, `docs/`, `uses/`) and is never walked. Inside a bucket, `git ls-files` decides: tracked files plus new ones git doesn't ignore, so junk (`.DS_Store`, `*.pyc`, `*~`) is kept out by `.gitignore`, and a file it ignores never gets linked.

The platform bucket is installed after `common/`, so a path present in both is **deliberately** won by the platform — the run prints `… from common overridden by macos`. That is the supported way to keep a mostly-shared config with one OS-specific variant. Two files of the same name in `linux/` and `macos/` never collide, since only one bucket is ever active: that is how `update-preferences` is one command with two implementations.

Skipping is not unlinking: a file moved between buckets leaves its old symlink behind on the other machine. `--prune` removes those — it unlinks foreign-bucket dests pointing into this repo, including links left dangling by the move, then drops the directories that empties. Left alone: real files, links pointing outside the repo, and anything the active buckets own — a shared-name command like `update-preferences` is installed, not foreign.

Package manifests are config, not repo files: `home/macos/.config/homebrew/Brewfile` (where `brew bundle --global` looks) and `home/linux/.config/pkgsync/pkglist*.txt`. They get symlinked like anything else, which is why they need no exclusion. `pkgsync` reads the *installed* copy, so `install.py` has to run before it.

Needs Python 3.10+, stdlib only; `ruff.toml` checks it against 3.10. macOS system `python3` is 3.9 and there is no `python` on `PATH`:

```
python3.13 install.py            # create the symlinks
python3.13 install.py --fake     # dry run — prints what it would link
python3.13 install.py --prune    # also unlink config for the other OS
python3.13 install.py --help     # all options
```

It never prompts.

After linking it runs every executable in `postinstall/<bucket>/` for the active buckets, in name order, so `postinstall/common/10-…` precedes `postinstall/linux/20-…`. A platform hook with the same name as a common one replaces it, same rule as the links. Hooks are for anything a symlink can't express — resolving a per-machine path, for example. A platform hook needs no OS guard; its directory is the guard. A hook reads config from its installed path under `$HOME`, not the repo, so it sees what the active buckets actually linked. They must be idempotent, exit non-zero on failure, and are skipped under `--fake`. `.py` hooks run with the same interpreter as `install.py`.

Confirm a new link landed — the arrow must point into `.dotfiles`:

```
ls -l ~/.config/foo/config.toml
# → /Users/<user>/.dotfiles/home/common/.config/foo/config.toml
```

`Symlink already points to ...` is the steady state for everything installed. `Destination exists` means a real file is sitting where the link should go — it needs `--force` (which moves it aside to `.bak`) or manual removal.

## Comments

Terse. One line, and only when the *why* is not obvious from the line below it — a tradeoff, a footgun, a non-obvious unit. Do not:

- restate what the setting or code already says
- enumerate a tool's option values or explain the ones not chosen — that is `--help`'s job
- write multi-line rationale; that belongs in the commit message

Same for code: no docstring on an obvious function, no narrating the next statement in prose.

## Conventions

- Repo path == home path, under whichever `home/` bucket applies. New tool config goes where it'd live under `$HOME`.
- Scripts in `home/*/.local/bin/` follow `docs/scripts.md`: names, the line-2 sentence, shebang, behavior. Read it before writing or editing one.
- Python anywhere in the repo, `install.py` and the hooks included, follows `docs/python.md`: stdlib first, ruff, code shape. Read it before writing or editing any.
- A web page a script serves or generates follows `docs/ui.md`: calm TUI look, Azulejo Brutalism colors, keys.
- A command whose per-OS implementations share nothing is two files of the same name, one per platform bucket — see `update-preferences`. One built from per-OS steps, like `sysupgrade` and `pkgsync`, is a `home/common/` runner over a `<name>.d/` whose parts sit in the buckets they apply to; a part sharing `linux/` with another distro's checks `/etc/os-release` and exits 0.
- No tests. Sanity-check with `python3.13 install.py --fake`, or reload the tool directly (`source ~/.zshrc`, `:source %`).
