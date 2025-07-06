export TREE_IGNORE="cache|log|logs|node_modules|vendor"
export PATH="/Users/${USER}/.local/bin:${PATH}"

export DOCKER_SCAN_SUGGEST=false
export EDITOR=nvim

function load_if_exists() { if [ -f "$1" ]; then source "$1"; fi; }

load_if_exists ~/.zshrc.$(hostname)
load_if_exists ~/.aliases
load_if_exists ~/.zshbindkeys
load_if_exists ~/.fzf.zsh
load_if_exists ~/.iterm2_shell_integration.zsh
load_if_exists ~/.cargo/env

[ ! -f ~/.direnvinit ] && direnv hook zsh >~/.direnvinit
source ~/.direnvinit

[ ! -f ~/.pyenvinit ] && pyenv init - >~/.pyenvinit
source ~/.pyenvinit

eval "$(fnm env --use-on-cd --shell zsh)"

eval "$(starship init zsh)"

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY_TIME
setopt EXTENDED_HISTORY

unsetopt share_history

export HISTSIZE=1000000000
export HISTFILESIZE=1000000000
export HISTTIMEFORMAT="%d/%m/%y %T  "
export HISTCONTROL=ignoredups:ignorespace
export HISTFILE="$HOME/.history"

# Add completitions
[ -d $HOME/.docker/completions ] && fpath=(/Users/mariocesar/.docker/completions $fpath)

[ ! -f ~/.just-completions ] && just --completions zsh >~/.just-completions
source ~/.just-completions

autoload -Uz compinit && compinit -i
