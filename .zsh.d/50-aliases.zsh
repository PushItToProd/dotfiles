[[ "$DEBUG" == "1" ]] && echo Configuring aliases

function reboot_required() {
    if [[ -e /var/run/reboot-required ]]; then
        cat /var/run/reboot-required
        return 0
    else
        return 1
    fi
}

alias pbcopy='xclip -sel clip'
alias pbpaste='xclip -sel clip -o'
alias open='xdg-open'
alias venv='source venv/bin/activate'

alias k='kubectl'
alias h='hledger'
alias hl='hledger'

alias l='ls -Ap'
alias l1='ls -Ap1'
alias ll='ls -lAp'

# From .bashrc
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias grep='grep -I --exclude-dir=.git'
alias fgrep='fgrep -I --exclude-dir=.git'
alias egrep='egrep -I --exclude-dir=.git'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto -I --exclude-dir=.git'
    alias fgrep='fgrep --color=auto -I --exclude-dir=.git'
    alias egrep='egrep --color=auto -I --exclude-dir=.git'
fi

alias gdiff='git diff --no-index --color-words'

randpass() {
  openssl rand -base64 "${1:-32}" | tr -d '\n'
}
