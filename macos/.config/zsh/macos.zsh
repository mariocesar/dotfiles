# path_helper only sets PATH — without shellenv, Homebrew's site-functions
# (_just, _fd, _gh, …) never reach fpath and compinit can't see them.
command -v brew >/dev/null && eval "$(brew shellenv)"

# libpq is keg-only, so the Brewfile install alone doesn't put psql on PATH
[ -d "$HOMEBREW_PREFIX/opt/libpq/bin" ] && export PATH="$HOMEBREW_PREFIX/opt/libpq/bin:$PATH"
