export PATH="$HOME/.local/bin:$PATH"
export TREE_IGNORE="cache|log|logs|node_modules|vendor"
export DOCKER_SCAN_SUGGEST=false
export EDITOR=nvim

# Better history behavior
export HISTSIZE=1000000000
export HISTFILESIZE=1000000000
export HISTTIMEFORMAT="%d/%m/%y %T  "
export HISTCONTROL=ignoredups:ignorespace
export HISTFILE="$HOME/.history"

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt INC_APPEND_HISTORY_TIME
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

load_if_exists ~/.zshrc.$(hostname)
load_if_exists ~/.aliases
load_if_exists ~/.fzf.zsh
load_if_exists ~/.iterm2_shell_integration.zsh
load_if_exists ~/.cargo/env

eval "$(direnv hook zsh)"

eval "$(mise activate zsh)"

eval "$(starship init zsh)"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
