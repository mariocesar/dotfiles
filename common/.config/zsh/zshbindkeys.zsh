# EDITOR=nvim makes zsh default to viins; these bindings are all emacs-style
bindkey -e

autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "\e[A" up-line-or-beginning-search
bindkey "\e[B" down-line-or-beginning-search
bindkey "\eOA" up-line-or-beginning-search
bindkey "\eOB" down-line-or-beginning-search

bindkey "\e[3~" delete-char
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
# tmux sends these for Home/End
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
# Ctrl+Right / Ctrl+Left
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word

fd_picker_opts=(--hidden --exclude .git --exclude .venv --exclude '.cache_*' --exclude node_modules)
# also used by fzf-edit in ~/.aliases
fzf_file_preview=(--preview 'bat --color=always --style=numbers --line-range=:500 -- {}' --preview-window 'right,60%,border-left')

# fzf's ^T offers the same set as ^P; the empty alt-c command keeps fzf from binding it, ^G does that job
FZF_CTRL_T_COMMAND="fd ${(@q)fd_picker_opts} --strip-cwd-prefix"
FZF_ALT_C_COMMAND=

# Alt+A inside the picker flips to everything (no excludes, no .gitignore); the prompt text is the toggle state
fzf-picker() {
  local prompt=$1 type=$2
  local some="fd --type $type ${(@q)fd_picker_opts} --strip-cwd-prefix"
  local all="fd --type $type --hidden --no-ignore --strip-cwd-prefix"
  local toggle="[[ \$FZF_PROMPT == '$prompt' ]] && echo 'change-prompt(All> )+reload($all)' || echo 'change-prompt($prompt)+reload($some)'"
  eval "$some" | fzf --prompt="$prompt" --bind "alt-a:transform:$toggle" "${@:3}"
}

search-and-edit() {
  local file
  file=$(fzf-picker 'Edit> ' f $fzf_file_preview)
  [[ -n $file ]] && nvim "$file"
  zle reset-prompt
}

zle -N search-and-edit

bindkey "^P" search-and-edit

search-directory-and-cd() {
  local dir
  dir=$(fzf-picker 'Dir> ' d)
  [[ -n $dir ]] && cd "$dir"
  zle reset-prompt
}

zle -N search-directory-and-cd

bindkey "^G" search-directory-and-cd

# the emacs keymap's ^U kills the whole line
bindkey "^U" backward-kill-line

# '/' out of WORDCHARS so ^W kills one path segment, not the whole path
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
