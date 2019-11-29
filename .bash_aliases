# defaults
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias tree='LC_COLLATE=C tree --dirsfirst -I "__pycache__|*.pyc|*~|.git|venv"'
alias tree-d='tree -d -L 1'
alias tree-dd='tree -d -L 2'
alias tree-ddd='tree -d -L 3'

# shortcuts
alias c='clear'
alias r='reset'
alias q='exit'

alias la='ls -A'
alias ll='ls -C -1'

alias cd..="cd .."
alias ..='cd ..'
alias ...='cd ../..'
alias -- -="cd -"

alias makepassword="pwgen -y -n 18 1"
alias proxy='ssh -C2qTnN -D 8080'
alias pp="ps axuf | pager"

alias vimrc="vim ~/.config/nvim/init.vim"

lt() { ls -ltrsa "$@" | tail; }

psgrep() { ps axuf | grep -v grep | grep "$@" -i --color=auto; }

truecolor() {
    awk 'BEGIN{
            s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
            for (colnum = 0; colnum<77; colnum++) {
                r = 255-(colnum*255/76);
                g = (colnum*510/76);
                b = (colnum*255/76);
                if (g>255) g = 510-g;
                printf "\033[48;2;%d;%d;%dm", r,g,b;
                printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
                printf "%s\033[0m", substr(s,colnum+1,1);
            }
            printf "\n";
        }'
}

