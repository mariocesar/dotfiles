export DOCKER_SCAN_SUGGEST=false
export EDITOR=nvim

# Better history behavior
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
export HISTFILE="$HOME/.history"

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# Load Zsh bindkeys
source ~/.config/zsh/zshbindkeys.zsh

function load_if_exists() { if [ -f "$1" ]; then source "$1"; fi; }

# Per-OS config; only the active platform's file exists. Must precede
# compinit — macos.zsh puts Homebrew's completions on fpath.
load_if_exists ~/.config/zsh/linux.zsh
load_if_exists ~/.config/zsh/macos.zsh

autoload -Uz compinit && compinit

# TokyoNight Night, to match ghostty; bg:-1 preserves the window transparency
export FZF_DEFAULT_OPTS="--layout=reverse --border=rounded --info=inline \
--color=bg:-1,bg+:#292e42,fg:#a9b1d6,fg+:#c0caf5,gutter:-1 \
--color=hl:#7aa2f7,hl+:#7dcfff,border:#545c7e,info:#565f89 \
--color=prompt:#7aa2f7,pointer:#bb9af7,marker:#9ece6a,header:#ff9e64"

# fzf ^R/^T and ** completion; before fzf-tab so fzf-tab keeps TAB
command -v fzf >/dev/null && source <(fzf --zsh)

# Completion styling; must come after compinit
source ~/.config/zsh/zshcompletion.zsh
source ~/.config/zsh/zshfzftab.zsh

load_if_exists ~/.aliases
load_if_exists ~/.zshrc.$(hostname)
load_if_exists ~/.cargo/env

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Guarded: a machine missing one of these should still get a working shell
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
command -v mise >/dev/null && eval "$(mise activate zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"

# bun completions
[ -s "/home/mariocesar/.bun/_bun" ] && source "/home/mariocesar/.bun/_bun"
