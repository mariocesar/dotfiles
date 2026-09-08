# fzf-tab replaces the completion menu with an fzf picker.
# Must load after compinit, and before any widget-wrapping plugin
# (zsh-autosuggestions, zsh-syntax-highlighting) if those ever get added.
# Arch (AUR) and Homebrew disagree on both the directory and the file name.
for _fzf_tab in /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh \
                /opt/homebrew/share/fzf-tab/fzf-tab.zsh \
                /usr/local/share/fzf-tab/fzf-tab.zsh; do
  if [[ -r $_fzf_tab ]]; then source $_fzf_tab; break; fi
done
unset _fzf_tab

# TokyoNight Night, to match ghostty; bg:-1 preserves the window transparency
zstyle ':fzf-tab:*' fzf-flags \
  --height=45% --layout=reverse --border=rounded --info=inline --cycle \
  --preview-window=right:55%:wrap:border-left \
  --color=bg:-1,bg+:#292e42,fg:#a9b1d6,fg+:#c0caf5,gutter:-1 \
  --color=hl:#7aa2f7,hl+:#7dcfff,border:#545c7e,info:#565f89 \
  --color=prompt:#7aa2f7,pointer:#bb9af7,marker:#9ece6a,header:#ff9e64

zstyle ':fzf-tab:*' prefix ''              # the group header already names the group
zstyle ':fzf-tab:*' switch-group '[' ']'
zstyle ':fzf-tab:*' fzf-min-height 15

zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza -1 --color=always --icons=always --group-directories-first $realpath'

zstyle ':fzf-tab:complete:(nvim|vim|bat|cat|less|head|tail|cp|mv|rm|chmod|source|wc):*' fzf-preview \
  '[[ -d $realpath ]] && eza -1 --color=always --icons=always --group-directories-first $realpath || bat --color=always --style=numbers --line-range=:200 $realpath'

zstyle ':fzf-tab:complete:git-(checkout|switch|merge|rebase|log|show|branch|cherry-pick):*' fzf-preview \
  'git log --oneline --graph --decorate --color=always --max-count=25 $word 2>/dev/null'

# delta needs the width told to it; inside a preview only fzf knows it
zstyle ':fzf-tab:complete:git-(add|diff|restore|stash):*' fzf-preview \
  'git diff --color=always -- $realpath | delta --paging=never --width=$FZF_PREVIEW_COLUMNS'

zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview \
  'SYSTEMD_COLORS=1 systemctl status --no-pager $word 2>&1'

zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  'ps -p $word -o pid,ppid,user,%cpu,%mem,etime,command 2>/dev/null'

zstyle ':fzf-tab:complete:man:*' fzf-preview 'whatis $word 2>/dev/null'
