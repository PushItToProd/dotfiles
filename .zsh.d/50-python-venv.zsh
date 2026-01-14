[[ "$DEBUG" == "1" ]] && echo Configuring Python helpers

DEFAULT_PYTHON=python3.14

PYTHON_VIRTUALENV_DIRS=(venv .venv)

find_venv_dir() {
  if [[ ! $PYTHON_VIRTUALENV_DIRS ]]; then
    echo "finding virtualenv failed: PYTHON_VIRTUALENV_DIRS is empty or unset" >&2
    return 2
  fi
  pushd . >/dev/null
  {
    local dirname
    while [[ "$PWD" != / ]]; do
      for dirname in $PYTHON_VIRTUALENV_DIRS; do
        if [[ -x $dirname/bin/python ]] && [[ -f $dirname/bin/activate ]]; then
          printf '%s/%s' "$PWD" "$dirname"
          return 0
        fi
      done
      cd .. || return 1
    done
  } always {
    popd >/dev/null
  }

  return 1
}

activate_venv_if_exists() {
  local venv_dir
  venv_dir="$(find_venv_dir)"
  if [[ $? == 2 ]]; then
    return 2
  fi

  if [[ "$venv_dir" ]]; then
    echo "Activating virtualenv in ${venv_dir}"
    source "${venv_dir}/bin/activate"
    return 0
  fi

  return 1
}

# activate a venv if one is found, otherwise offer to create one
venv() {
  activate_venv_if_exists
  local exit=$?
  if [[ $exit == 0 || $exit == 2 ]]; then
    return
  fi

  # TODO: use uv
  #
  # local reply
  # if command -v uv &>/dev/null; then
  #   read "reply?virtualenv not available. create one with uv? (Y/n) "
  #   case $reply in
  #   [Yy]*) TODO
  #   esac
  # fi

  local cmd="$1"
  if [[ ! "$cmd" ]]; then
    read "cmd?venv not available. create one? (Y/n/version) [default: $DEFAULT_PYTHON] "
  fi

  case $cmd in
    [Yy]*|''|-y) cmd="$DEFAULT_PYTHON" ;;
    ^[0-9]) cmd="python$cmd" ;;
  esac

  [[ -x "$cmd" ]] || command -v "$cmd" &>/dev/null || {
    echo "Not found: $cmd"
    return 1
  }

  echo "Creating virtualenv using $cmd in $PWD/venv" >&2
  $cmd -m venv venv
  source venv/bin/activate
}

alias de=deactivate

# TODO: implement automated venv activation on cd
#cd_venv_handler() {
#
#}
#chpwd_functions=(${chpwd_functions[@]} "cd_venv_handler")
