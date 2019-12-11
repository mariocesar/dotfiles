# defaults
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ls='exa --group-directories-first'
alias l='ls -1'
alias ll='ls -l'
alias la='ls -al'
alias ls1='ls --tree --depth=2'
alias ls2='ls --tree --depth=3'
alias ls3='ls --tree --depth=4'
alias ls4='ls --tree --depth=5'

alias tree='LC_COLLATE=C tree --dirsfirst -I "__pycache__|*.pyc|*~|.git|venv"'
alias tree1='tree -d -L 1'
alias tree2='tree -d -L 2'
alias tree3='tree -d -L 3'

# shortcuts
alias c='clear'
alias r='reset'
alias q='exit'

alias cd..="cd .."
alias ..='cd ..'
alias ...='cd ../..'
alias -- -="cd -"

alias makepassword="pwgen -y -n 18 1"
alias proxy='ssh -C2qTnN -D 8080'
alias pp="ps axuf | pager"

alias vimrc="vim ~/.config/nvim/init.vim"

function p() {
    # https://github.com/junegunn/fzf/wiki/examples#changing-directory
    # Example: vim $(p)
    fzf --preview '
        [[ $(file --mime {}) =~ binary ]] && 
         echo {} is a binary file ||
         (highlight -O ansi -l {} || cat {}) 2> /dev/null | head -500
    '
}

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

