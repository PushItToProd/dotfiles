[[ "$DEBUG" == "1" ]] && echo Configuring Python helpers

venv() {
  if [[ -d venv ]]; then
    source venv/bin/activate
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

