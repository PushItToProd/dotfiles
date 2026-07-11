alias _tmux="command -p tmux"

__tmux_try_attach() {
  # any args provided => invoke tmux normally
  if [[ "$#" -gt 0 ]]; then
    _tmux "$@"
    return
  fi
  # no args => try attaching to existing session, otherwise start normally
  _tmux attach || _tmux
}

function my-tmux-attach {
  local arg="$1"
  case "$arg" in
    ''|-*) tmux a "$@" ;;
    # arg provided and doesn't start with a `-` => assume first arg is a session
    # identifier
    *) tmux a -t "$@" ;;
  esac
}

alias tmux=__tmux_try_attach

alias t='tmux'
alias ta='my-tmux-attach'
alias tat='my-tmux-attach'
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
