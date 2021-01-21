source ~/.shell_provision

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="spaceship"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
    command-not-found
    docker
)

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

SPACESHIP_PROMPT_ADD_NEWLINE=false

[ -z "$SSH_CONNECTION" ] && ZSH_TMUX_AUTOSTART="true"

ZSH_AUTOSUGGEST_USE_ASYNC="true"
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste accept-line)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source "${HOME}/.zgen/zgen.zsh"

if ! zgen saved; then
    zgen oh-my-zsh
    zgen load zsh-users/zsh-completions src
    zgen load denysdovhan/spaceship-prompt spaceship
    zgen save
fi

source ~/.shell_envs
source ~/.shell_aliases

if [ -f ~/.zshrc.$(hostname) ]; then
    source ~/.zshrc.$(hostname)
fi

if [ -f ~/.tnsrc ]; then
    source ~/.tnsrc
fi
