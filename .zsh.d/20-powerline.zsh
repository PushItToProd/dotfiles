# -*- mode: sh -*-
[[ "$DEBUG" == "1" ]] && echo "Configuring powerline"

if ! command -v powerline-shell &>/dev/null; then
  if [[ ! "$ZSH_D_DISABLE_POWERLINE_WARNING" ]]; then
    echo "warning: powerline-shell is not installed" >&2
  fi
  return
fi

function powerline_precmd() {
  # Hack required for ~/bin/powerline_segments/wrap.py to properly wrap text.
  read TERM_ROWS TERM_COLUMNS < <(stty size)
  export TERM_ROWS TERM_COLUMNS
  PS1="$(powerline-shell --shell zsh $?)"
}

function install_powerline_precmd() {
  for s in "${precmd_functions[@]}"; do
    if [ "$s" = "powerline_precmd" ]; then
      return
    fi
  done
  precmd_functions+=(powerline_precmd)
}

if [[ "$TERM" == "linux" ]]; then
  if [[ ! "$ZSH_D_DISABLE_POWERLINE_WARNING" ]]; then
    echo "warning: TERM=$TERM - not powerline-shell precmd hook even though powerline-shell is installed" >&2
  fi
  return
fi
install_powerline_precmd
