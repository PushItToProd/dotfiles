alias _tmux="command -p tmux"

__tmux() {
  if [[ "$#" -gt 0 ]]; then
    _tmux "$@"
    return
  fi
  _tmux attach || _tmux
}

alias tmux=__tmux

alias tls='tmux ls'
alias tnew='tmux new'
alias ta0='tmux a -t 0'
alias ta1='tmux a -t 1'
alias ta2='tmux a -t 2'
alias ta3='tmux a -t 3'
alias ta4='tmux a -t 4'
alias ta5='tmux a -t 5'
alias ta6='tmux a -t 6'
alias ta7='tmux a -t 7'
alias ta8='tmux a -t 8'
alias ta9='tmux a -t 9'
alias t='tmux'

function ta {
  local arg="$1"
  case "$arg" in
    ''|-*) tmux a "$@" ;;
    *) tmux a -t "$@" ;;
  esac
}
