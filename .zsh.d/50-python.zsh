[[ "$DEBUG" == "1" ]] && echo Configuring Python helpers

# recurse up the directory tree to find a virtualenv directory
find_venv() {
  # on principle, I refuse to support virtualenvs in /
  if [[ "$(pwd)" == / ]]; then
    return
  fi

  if [[ -d venv ]]; then
    pwd
    return
  fi

  pushd .. >/dev/null
  find_venv
  popd >/dev/null
}

venv() {
  local -r venv_location="$(find_venv)"

  if [[ "$venv_location" ]]; then
    echo "Activating virtualenv in ${venv_location}"
    source "${venv_location}/venv/bin/activate"
    return
  fi

  local create_venv
  read "create_venv?venv not available. create one? (Y/n) "
  if [[ "$create_venv" =~ ^[Yy] ]] || [[ "$create_venv" = "" ]]; then
    echo "Creating virtualenv" >&2
    python3.8 -m venv venv
    source venv/bin/activate
  fi
}

