
# defaults
alias ls='LC_COLLATE=C ls -F --color=auto --human-readable --group-directories-first '
alias tree='LC_COLLATE=C tree --dirsfirst -I "__pycache__|*.pyc|*~" '

# shortcuts
alias c='clear'
alias r='reset'
alias q='exit'


alias ll='ls -alF'
alias la='ls -A'
alias l='ls -C -1'

alias cd..="cd .."
alias ..='cd ..'
alias ...='cd ../..'
alias -- -="cd -"

alias proxy='ssh -C2qTnN -D 8080'

# Python and Dango related

activate() { source `find . -ipath '*/bin/activate'`; }

runserver() { python manage.py runserver --traceback $@; }

# Unix stuff
# ----------

alias explore="ranger"
alias pp="ps axuf | pager"

lt() { ls -ltrsa "$@" | tail; }
psgrep() { ps axuf | grep -v grep | grep "$@" -i --color=auto; }

# Tools
# -----

streaming() {
   # streaming streamkeyhere

    INRES="1920x1080"; # input resolution
    OUTRES="1920x1080"; # output resolution
  	FPS="15"; # target FPS
    GOP="30"; # i-frame interval, should be double of FPS,
    GOPMIN="15"; # min i-frame interval, should be equal to fps,
    THREADS="2"; # max 6
    CBR="1000k"; # constant bitrate (should be between 1000k - 3000k)
    QUALITY="ultrafast";  # one of the many FFMPEG preset
    AUDIO_RATE="44100"
    STREAM_KEY="$1"; # use the terminal command Streaming streamkeyhere to stream your video to twitch or justin
    SERVER="live-fra"; # twitch server in frankfurt, see http://bashtech.net/twitch/ingest.php for list

    ffmpeg -f x11grab -s "$INRES" -r "$FPS" -i :0.0 -f alsa -i pulse -f flv \
    	-ac 2 -ar $AUDIO_RATE -vcodec libx264 -g $GOP -keyint_min $GOPMIN \
    	-b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p -s $OUTRES \
    	-preset $QUALITY -tune film -acodec libmp3lame -threads $THREADS -strict normal \
        -bufsize $CBR "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY";

}

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
