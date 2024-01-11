export TREE_IGNORE="cache|log|logs|node_modules|vendor"
export PATH="/Users/mariocesar/.local/bin:${PATH}"
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
