[[ "$DEBUG" == "1" ]] && echo Configuring Python helpers

DEFAULT_PYTHON=python3.10

# recurse up the directory tree to find a virtualenv directory
find_venv() {
  # on principle, I refuse to support virtualenvs in /
  if [[ "$(pwd)" == / ]]; then
    return 1
  fi

  if [[ -d venv ]]; then
    pwd
    return 0
  fi

  pushd .. >/dev/null
  find_venv
  popd >/dev/null
}

activate_venv_if_exists() {
  local -r venv_location="$(find_venv)"

  if [[ "$venv_location" ]]; then
    echo "Activating virtualenv in ${venv_location}"
    source "${venv_location}/venv/bin/activate"
    return 0
  fi

  return 1
}

# activate a venv if one is found, otherwise offer to create one
venv() {
  if activate_venv_if_exists; then
    return
  fi

  local cmd="$1"
  if [[ ! "$cmd" ]]; then
    read "cmd?venv not available. create one? (Y/n/version) "
  fi

  case $cmd in
    [Yy]*|''|-y) cmd="$DEFAULT_PYTHON" ;;
    ^[0-9]) cmd="python$cmd" ;;
  esac

  # if [[ "$cmd" =~ ^[Yy] ]] || [[ "$cmd" == "" ]] || [[ "$cmd" == -y ]]; then
  #   cmd="python3.9"
  # elif [[ "$cmd" =~ ^[0-9] ]]; then
  #   cmd="python$cmd"
  # fi
  [[ -x "$cmd" ]] || command -v "$cmd" &>/dev/null || {
    echo "Not found: $cmd"
    return 1
  }

  echo "Creating virtualenv using $cmd" >&2
  $cmd -m venv venv
  source venv/bin/activate
}

alias de=deactivate

python() {
  "$(whence -p python || whence -p "$DEFAULT_PYTHON")" "$@"
}

# TODO: implement automated venv activation on cd
#cd_venv_handler() {
#
#}
#chpwd_functions=(${chpwd_functions[@]} "cd_venv_handler")
