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

alias l=less
#alias l='ls -F'
alias ll='ls -lh'
alias la='ls -lah'
alias lt='ls --human-readable --size --sort=size --classify --format=single-column'
alias lastmodified='ls -tl'

alias grep='grep -I --exclude-dir=.git'
alias fgrep='fgrep -I --exclude-dir=.git'
alias egrep='egrep -I --exclude-dir=.git'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    __grep_defaults='--color=auto -I --exclude-dir=.git --exclude-dir=venv'

    alias grep="grep $__grep_defaults"
    alias fgrep="fgrep $__grep_defaults"
    alias egrep="egrep $__grep_defaults"
fi

function llss {
  if [[ -d "$1" ]]; then
    ls -l "$1"
  else
    less "$1"
  fi
}

alias untar='tar --extract --verbose --file'
