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

alias l='ls -Ap'
alias l1='ls -Ap1'
alias ll='ls -lAp'

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
