export EDITOR=nvim
export DOCKER_CLI_HINTS=false

function load_if_exists() { if [ -f "$1" ]; then source "$1"; fi; }
function command_exists() { command -v "$1" >/dev/null; }

# History
HISTSIZE=1000000000
SAVEHIST=$HISTSIZE
HISTFILE="$HOME/.history"

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

# Keys
source ~/.config/zsh/zshbindkeys.zsh

# Platform; before compinit
load_if_exists ~/.config/zsh/macos.zsh

# Completion
autoload -Uz compinit && compinit

# TokyoNight; bg:-1 keeps transparency
export FZF_DEFAULT_OPTS="--layout=reverse --border=rounded --info=inline \
--preview-window=right,60%,border-left \
--color=bg:-1,bg+:#292e42,fg:#a9b1d6,fg+:#c0caf5,gutter:-1 \
--color=hl:#7aa2f7,hl+:#7dcfff,border:#545c7e,info:#565f89 \
--color=prompt:#7aa2f7,pointer:#bb9af7,marker:#9ece6a,header:#ff9e64"

# fzf before fzf-tab
command_exists fzf && source <(fzf --zsh)
source ~/.config/zsh/zshcompletion.zsh
source ~/.config/zsh/zshfzftab.zsh
load_if_exists ~/.bun/_bun

# Aliases and functions
source ~/.config/zsh/worktree.zsh
load_if_exists ~/.aliases

# Per-machine
load_if_exists ~/.zshrc.$(hostname)

# PATH; above mise
load_if_exists ~/.cargo/env
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
command_exists go && \
  export PATH="$PATH:$(go env GOPATH)/bin"

# Hooks
command_exists direnv && eval "$(direnv hook zsh)"
command_exists mise && eval "$(mise activate zsh)"
command_exists starship && eval "$(starship init zsh)"
command_exists notes && eval "$(notes zsh)"
