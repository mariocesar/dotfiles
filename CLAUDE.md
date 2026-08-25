# CLAUDE.md

Personal dotfiles (macOS + Linux/niri). No build/lint/test pipeline — verify by symlinking into `$HOME` and using the tool.

## install.py

Symlinks every non-excluded file to the same relative path under `$HOME` (`.config/nvim/init.lua` → `~/.config/nvim/init.lua`). Exclusions live in `DotfileMapper.EXCLUDE_PATTERNS`; add repo-management files there, not new config — new dirs/files are picked up automatically.

```
python install.py --help     # Will show all the options and actions available
```

## Conventions

- Repo path == home path, always. New tool config goes where it'd live under `$HOME`.
- Shell scripts in `.local/bin/` start with `set -eu`/`-euo pipefail`.
- No tests. Sanity-check with `python install.py --fake`, or reload the tool directly (`source ~/.zshrc`, `:source %`).
