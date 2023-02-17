[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval source <(/usr/local/bin/starship init zsh --print-full-init)

TREE_IGNORE="cache|log|logs|node_modules|vendor"

export PATH="/Users/mariocesar/.local/bin:${PATH}"
export DOCKER_SCAN_SUGGEST=false
export EDITOR=nvim

eval "$(direnv hook zsh)"

source ~/.aliases
source ~/.zshbindkeys

test -f ~/.pyenvrc && source ~/.pyenvrc ||:
test -f ~/.zshrc.$(hostname) && source ~/.zshrc.$(hostname) ||:
