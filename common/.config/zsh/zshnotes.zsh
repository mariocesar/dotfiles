# vim: set filetype=zsh :
#
# notes: the filesystem is the database.
#   ~/.notes is the library; a notebook is a directory; a note is a Markdown file, usable without the command.
#   home/<path> mirrors a container under $HOME (git root, else cwd); named/<name> is an explicit notebook.
#   Identity is the logical path relative to $HOME: no realpath, no hashes, no registry, no config.
#   notes.md is every notebook's persistent note; `today` is a file-naming policy, not a kind of notebook.
# notes.py only resolves paths and creates files: one path on stdout, never an editor, never rendering.
#   Everything on top (edit, browse, search, pick) is composed here from that path.
#   A new kind of path goes in notes.py; a new way to use a path goes here; nothing a pipe can do goes in the script.
#   Mirrored dot-dirs (home/.ssh) are hidden: rg --hidden, fd -H, glow -a.
#   n, nn, nj and nf open nvim-autosave (~/.local/bin): nvim whose buffers write themselves.
# `notes` is an alias so the script keeps its .py. Only zsh sees it: anything that execs the
#   command directly (nvim :!, scripts, other shells) must call notes.py.

alias notes=notes.py

# Args pass through to `notes`, so `n -n global` edits the global notebook;
# except where the wrapped tool owns them: nn (title), ns/nsa (rg pattern).
function n() {      # this notebook's notes.md
  local f; f="$(notes "$@" file)" || return
  nvim-autosave "$f"
}
function nn() {     # new note; args are the title: nn postgres locking
  local f; f="$(notes new "$@")" || return
  nvim-autosave "$f"
}
function nj() {     # today's journal entry
  local f; f="$(notes -n journal today)" || return
  nvim-autosave "$f"
}
function nb()  { glow -a "$(notes "$@")" }                   # browse
function ns()  { rg --hidden -i "$@" "$(notes)" }            # search this notebook
function nsa() { rg --hidden -i "$@" ~/.notes }              # search the library
function nf() {     # pick a note to edit
  fd -H -e md . "$(notes "$@")" |
    fzf --prompt='note> ' $fzf_file_preview --bind 'enter:become(nvim-autosave -- {})'
}
function ncd() { cd "$(notes "$@")" }
