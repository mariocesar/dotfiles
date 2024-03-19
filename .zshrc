export TREE_IGNORE="cache|log|logs|node_modules|vendor"
export PATH="/Users/${USER}/.local/bin:${PATH}"

export DOCKER_SCAN_SUGGEST=false
export EDITOR=nvim

[ -f ~/.zshrc.$(hostname) ] && source ~/.zshrc.$(hostname)
[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.zshbindkeys ] && source ~/.zshbindkeys
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ ! -f ~/.direnvinit ] && direnv hook zsh > ~/.direnvinit
source ~/.direnvinit

[ ! -f ~/.pyenvinit ] && pyenv init - > ~/.pyenvinit
source ~/.pyenvinit

eval "$(starship init zsh)"

[ -e "${HOME}/.iterm2_shell_integration.zsh" ] && source "${HOME}/.iterm2_shell_integration.zsh"

[ -f "${HOME}/.zshrc.$(hostname).zsh" ] && source "${HOME}/.zshrc.$(hostname).zsh" ]

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

autoload -Uz compinit && compinit -i
