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

function _my_tmux_attach {
  local arg="$1"
  case "$arg" in
    ''|-*) tmux a "$@" ;;
    # arg provided and doesn't start with a `-` => assume first arg is a session
    # identifier
    *) tmux a -t "$@" ;;
  esac
}

function _my_tmux_new {
  local arg1="$1"
  # TODO: add a `--pwd` flag to name the session after the current project dir
  case "$arg1" in
    ''|-*) tmux new-session "$@" ;;
    # arg provided and doesn't start with a `-` => assume first arg is a session
    # identifier
    *) tmux new-session -s "$@" ;;
  esac
}

alias tmux=__tmux_try_attach

alias t='tmux'
alias ta='_my_tmux_attach'
alias tat='_my_tmux_attach'
alias tls='tmux ls'
alias tnew='_my_tmux_new'

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
