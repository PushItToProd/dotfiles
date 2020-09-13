[[ "$DEBUG" == "1" ]] && echo Configuring aliases

alias k='kubectl'

# From .bashrc
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias gdiff='git diff --no-index --color-words'
alias g=git
alias gs='git s'
alias gd='git d'
alias gds='git ds'
alias gc='git c'
alias gca='git ca'

alias e='emacs'
alias enw='emacs -nw'

randpass() {
  openssl rand -base64 "${1:-32}" | tr -d '\n'
}

alias ts=ts-node