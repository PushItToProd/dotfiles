alias _tmux="command -p tmux"

__tmux() {
  if [[ "$#" -gt 0 ]]; then
    _tmux "$@"
    return
  fi
  _tmux attach || _tmux
}

alias tmux=__tmux
