# Sourced after compinit — zstyle is inert until the completion system exists.

setopt COMPLETE_IN_WORD   # complete from the cursor instead of jumping to the word end first
setopt ALWAYS_TO_END      # ...then move to the end once a match is inserted
setopt AUTO_PARAM_SLASH
setopt PATH_DIRS          # `bin/foo<TAB>` also searches $PATH entries
unsetopt MENU_COMPLETE    # show the picker, never silently insert the first match

zstyle ':completion:*' menu no   # fzf-tab needs zsh's own menu out of the way
zstyle ':completion:*' group-name ''   # keeps git's commands/branches/tags in separate blocks
zstyle ':completion:*' verbose yes
zstyle ':completion:*' special-dirs true

zstyle ':completion:*:descriptions' format '[%d]'   # plain: fzf-tab drops escape sequences here
zstyle ':completion:*:messages'     format '%F{magenta}%d%f'
zstyle ':completion:*:warnings'     format '%F{red}no matches for %d%f'
zstyle ':completion:*:corrections'  format '%F{yellow}%d %F{red}(errors: %e)%f'

# LS_COLORS is unset here (eza is the ls), so the palette is spelled out
zstyle ':completion:*' list-colors 'di=34:ln=36:ex=32:pi=33:so=33:bd=33;1:cd=33;1'

# exact, then case-insensitive, then infix: `git co fea<TAB>` reaches feature/…
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Za-z}' 'l:|=* r:|=*'

# last resort, so a typo still completes
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# _git forks git many times per TAB; this is what makes it feel instant in big repos
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# git orders these by recency; alphabetising them buries the branch you just left
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-switch:*' sort false

zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w'
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other   # don't re-offer an argument already on the line
