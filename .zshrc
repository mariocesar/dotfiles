export PATH="${HOME}/.local/bin:${PATH}"

SPACESHIP_GIT_STATUS_SHOW=false
SPACESHIP_USER_SHOW=true
SPACESHIP_HOST_SHOW=true
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_ORDER=(
    user          # Username section
    dir           # Current directory section
    host          # Hostname section
    git           # Git section (git_branch + git_status)
    pyenv
    line_sep      # Line break
    exit_code     # Exit code section
    char          # Prompt character
)

echo -n "Loading zplug"

export ZPLUG_HOME=${HOME}/.zplug
source $ZPLUG_HOME/init.zsh

zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme

if ! zplug check; then
    zplug install
fi

zplug load

echo " [done]"

source "${HOME}/.aliases"

if [ -f ~/.zshrc.$(hostname) ]; then
    source ~/.zshrc.$(hostname)
fi
