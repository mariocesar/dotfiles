# path_helper only sets PATH — without shellenv, Homebrew's site-functions
# (_just, _fd, _gh, …) never reach fpath and compinit can't see them.
command -v brew >/dev/null && eval "$(brew shellenv)"
