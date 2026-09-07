# EDITOR=nvim makes zsh default to viins; these bindings are all emacs-style
bindkey -e

autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# History search
bindkey "\e[A" up-line-or-beginning-search
bindkey "\e[B" down-line-or-beginning-search
bindkey "\eOA" up-line-or-beginning-search
bindkey "\eOB" down-line-or-beginning-search

bindkey "\e[3~" delete-char
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line

# Shift+Tab cycles completions backward
bindkey "\e[Z" reverse-menu-complete

fd_picker_opts=(--hidden --exclude .git --exclude .venv --exclude '.cache_*' --exclude node_modules)

# Alt+A inside the picker flips to everything (no excludes, no .gitignore); the prompt text is the toggle state
fzf-picker() {
  local prompt=$1 type=$2
  local some="fd --type $type ${(@q)fd_picker_opts} --strip-cwd-prefix"
  local all="fd --type $type --hidden --no-ignore --strip-cwd-prefix"
  local toggle="[[ \$FZF_PROMPT == '$prompt' ]] && echo 'change-prompt(All> )+reload($all)' || echo 'change-prompt($prompt)+reload($some)'"
  eval "$some" | fzf --select-1 --exit-0 --prompt="$prompt" --bind "alt-a:transform:$toggle"
}

# Search and open in Vim

search-and-edit() {
  local file
  file=$(fzf-picker 'Edit> ' f)
  [[ -n $file ]] && nvim "$file"
  zle reset-prompt
}

zle -N search-and-edit

bindkey "^P" search-and-edit

# Search for directory and change to it

search-directory-and-cd() {
  local dir
  dir=$(fzf-picker 'Dir> ' d)
  [[ -n $dir ]] && cd "$dir"
  zle reset-prompt
}

zle -N search-directory-and-cd

bindkey "^G" search-directory-and-cd

# Ctrl + U to delete from the cursor to the beginning of the line
bindkey "^U" backward-kill-line

