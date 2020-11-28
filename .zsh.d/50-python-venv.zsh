[[ "$DEBUG" == "1" ]] && echo Configuring Python helpers

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

  local create_venv
  read "create_venv?venv not available. create one? (Y/n) "
  if [[ "$create_venv" =~ ^[Yy] ]] || [[ "$create_venv" = "" ]]; then
    echo "Creating virtualenv" >&2
    python3.9 -m venv venv
    source venv/bin/activate
  fi
}

alias de=deactivate

# TODO: implement automated venv activation on cd
#cd_venv_handler() {
#
#}
#chpwd_functions=(${chpwd_functions[@]} "cd_venv_handler")
