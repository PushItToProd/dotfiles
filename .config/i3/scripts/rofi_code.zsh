#!/usr/bin/env zsh

# dump all workspaces using jq
_list_workspaces() {
  jq -r '
    if .folder
    then .folder
    else .configuration.external
    end
  ' /home/joe/.config/Code/User/workspaceStorage/*/workspace.json
}

# printable workspace name
get_friendly_ws_name() {
  local ws="$1"
  ws="$(get_ws_path "$ws")"
  if [[ "$ws" == "null" ]] || [[ "$ws" == "" ]]; then
    return
  fi

  # strip homedir
  local cleaned="${ws##$HOME/}"
  if [[ "$cleaned" != "$ws" ]]; then
    # add `~/` into the string to denote it's relative to the homedir
    cleaned="~/$cleaned"
  fi
  printf '%s\n' "$cleaned"
}

# clean workspace name so it can be passed as a path
get_ws_path() {
  local ws="$1"
  if [[ "$ws" == "null" ]]; then
    return
  fi
  ws="${ws##'file://'}"
  printf '%s\n' "$ws"
}

list_workspaces() {
  local ws
  while read -r ws; do
    get_friendly_ws_name "$ws"
  done < <(_list_workspaces)
}

list_workspaces_rofi() {
  local ws friendly
  while read -r ws; do
    friendly=$(get_friendly_ws_name "$ws")
    # pass raw workspace name as row info option
    printf '%s\0info\x1f%s\n' "$friendly" "$ws"
  done < <(_list_workspaces)
}

handle_selection() {
  local selection="$ROFI_INFO"

  local ws_path
  ws_path="$(get_ws_path "$selection")"
  echo ws_path = $ws_path >&2
  code -n $ws_path
}

rofi_main() {
  if (( $# == 0 )); then
    list_workspaces_rofi
    return
  fi

  handle_selection "$*" &
}

main() {
  if [[ -v ROFI_RETV ]]; then
    rofi_main "$@"
    return
  fi

  case "$1" in
    ls|list)
      list_workspaces
      return
      ;;
  esac

  rofi -show code -modi "code:$PROGNAME"
}
if [[ $ZSH_EVAL_CONTEXT == toplevel ]]; then
  PROGNAME="$0"
  main "$@"
fi