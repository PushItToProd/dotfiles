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

dir_is_not_empty() {
  # check visible files
  {
    : "$1"/*
    return 0  # found visible files
  } always {
    TRY_BLOCK_ERROR=0
  }

  # check hidden files
  {
    : "$1"/.*
    return 0
  } always {
    TRY_BLOCK_ERROR=0
  }

  return 1
} 2>/dev/null

dir_is_empty() {
  ! dir_is_not_empty "$@"
}


# like ls and less smashed into one
function llss {
  if [[ $# == 1 ]]; then
    # if there's one argument and it's a file, open it with less
    if [[ -f "$1" ]]; then
      less "$1"
      return
    fi


    if dir_is_empty "$1"; then
      echo "empty directory: $1" >&2
    fi
  fi

  ls "$@"
}

alias untar='tar --extract --verbose --file'
alias python='python3.9'