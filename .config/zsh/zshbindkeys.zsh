# EDITOR=nvim makes zsh default to viins; these bindings are all emacs-style
bindkey -e

autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# History search
bindkey "^R" history-incremental-search-backward
bindkey "\e[A" up-line-or-beginning-search
bindkey "\e[B" down-line-or-beginning-search
bindkey "\eOA" up-line-or-beginning-search
bindkey "\eOB" down-line-or-beginning-search

bindkey "\e[1~" beginning-of-line
bindkey "\e[2~" quoted-insert
bindkey "\e[3~" delete-char
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
bindkey "\e[7~" beginning-of-line
bindkey "\e[8~" end-of-line
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line

# Shift+Tab cycles completions backward
bindkey "\e[Z" reverse-menu-complete

# Search and open in Vim

search-and-edit() {
  local file
  file=$(fd --type f --strip-cwd-prefix | fzf --select-1 --prompt="Edit> ")
  [[ -n $file ]] && nvim "$file"
  zle reset-prompt
}

zle -N search-and-edit

bindkey "^P" search-and-edit

# Search for directory and change to it

search-directory-and-cd() {
  local dir
  dir=$(fd --type d | fzf --select-1 --exit-0 --prompt="Dir> ")
  [[ -n $dir ]] && cd "$dir"
  zle reset-prompt
}

zle -N search-directory-and-cd

bindkey "^G" search-directory-and-cd

# Ctrl + U to delete from the cursor to the beginning of the line
bindkey "^U" backward-kill-line

# Ctrl + K to delete from the cursor to the end of the line
bindkey "^K" kill-line
