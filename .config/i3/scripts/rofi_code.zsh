#!/usr/bin/env zsh
# rofi_code.zsh implements a custom rofi mode for launching VS Code workspaces.

# FIXME this script feels overly-complicated and could probably stand to be
# simplified

# TODO implement some way of deleting workspaces that aren't useful (maybe a
# keybinding)

# TODO implement a way of pinning workspaces to the top of the list for easy
# access.

# XXX alternatively, figure out how to sort workspaces by most recently used.
# -> It looks like each directory contains a state.vscdb file that gets modified
# each time the workspace is used.

readonly PROGPATH="${(%):-%N}"
readonly PROGDIR="${PROGPATH:A:h}"

# dump all workspaces using jq
_list_workspaces() {
  jq -L"$PROGDIR" -r '
    include "urldecode";
    (.folder // .workspace // .configuration.external) | urldecode
  ' $HOME/.config/Code/User/workspaceStorage/*/workspace.json
}

# abbreviate_homedir takes a path and, if it is located within the user's
# home directory, shortens it to begin with ~
abbreviate_homedir() {
  # here the # before $HOME indicates that the pattern must match at the start
  # of the string (see: man zshexpn)
  printf '%s' "${1/#$HOME/~}"
}

# get_friendly_ws_name takes the full path to a workspace and returns a friendly
# path with the file:// prefix removed and the user's homedir replaced with ~
get_friendly_ws_name() {
  local ws="$1"
  ws="$(strip_file_protocol "$ws")"
  if [[ "$ws" == "null" ]] || [[ "$ws" == "" ]]; then
    return
  fi

  printf '%s\n' "$(abbreviate_homedir "$ws")"
}

# strip_file_protocol removes the file:// protocol from the start of the given
# path
strip_file_protocol() {
  local ws="$1"
  if [[ "$ws" == "null" ]]; then
    return
  fi
  ws="${ws#'file://'}"
  printf '%s\n' "$ws"
}

# list_workspaces produces a plain list of workspaces for testing purposes
list_workspaces() {
  local ws
  while read -r ws; do
    echo "$(get_friendly_ws_name "$ws") ($ws)"
  done < <(_list_workspaces)
}

# list_workspaces_rofi produces a list of workspaces for rofi to display
list_workspaces_rofi() {
  local ws ws_path friendly
  while read -r ws; do
    friendly=$(get_friendly_ws_name "$ws")
    # pass raw workspace name as row info option
    printf '%s\0info\x1f%s\n' "$friendly" "$ws"
  done < <(_list_workspaces)
}

# handle_selection takes the selection from rofi and invokes VS Code with it
handle_selection() {
  local selection="$ROFI_INFO"

  local ws_path
  ws_path="$(strip_file_protocol "$selection")"
  echo ws_path = $ws_path >&2

  # unset rofi's environment variables to prevent issues when testing
  # rofi-related scripts in the launched VS Code process. otherwise, these
  # variables will remain set in VS Code's integrated terminal, which will cause
  # scripts like this one to behave as if they're being called by rofi
  unset ROFI_RETV ROFI_INFO ROFI_OUTSIDE

  code -n $ws_path
}

# rofi_main implements the main rofi mode. If no arguments are provided, it
# emits a list of workspaces. If an argument is provided, it launches the
# corresponding workspace in VS Code.
rofi_main() {
  # TODO: use ROFI_RETV to determine behavior
  if (( $# == 0 )); then
    list_workspaces_rofi
    return
  fi

  handle_selection "$*" &
}

# the main entrypoint for the script
main() {
  # if ROFI_RETV is set, then we're invoked from within rofi
  if [[ -v ROFI_RETV ]]; then
    rofi_main "$@"
    return
  fi

  # if ROFI_RETV is not set, try handling commands from the user
  case "$1" in
    ls|list)
      list_workspaces
      return
      ;;
  esac

  # otherwise, launch rofi
  rofi -show code -modi "code:$PROGNAME"
}
if [[ $ZSH_EVAL_CONTEXT == toplevel ]]; then
  PROGNAME="$0"
  main "$@"
fi