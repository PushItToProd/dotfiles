#!/usr/bin/env zsh
# rofi_code.zsh implements a custom rofi mode for launching VS Code workspaces.
# It's mainly a wrapper around my list_vscode_workspaces command implemented in
# Go.

# TODO implement some way of deleting workspaces that aren't useful (maybe a
# keybinding)

# TODO implement a way of pinning workspaces to the top of the list for easy
# access.

readonly PROGPATH="${(%):-%N}"
readonly PROGDIR="${PROGPATH:A:h}"
readonly WORKSPACE_STORAGE_PATH="$HOME/.config/Code/User/workspaceStorage"

rofi_error() {
  echo -e "\0prompt\x1fError!"
  echo -e "\0no-custom\x1ftrue"
  echo -e "\0data\x1fFAIL"
  echo -e "\0urgent\x1f0,1"
  echo -e "Error: $*\0urgent\x1ftrue"
  echo -e "Please add Go to your shell profile script and try again."
}

ensure_go() {
  if ! command -v go &>/dev/null; then
    rofi_error "Go is not installed or isn't on the PATH"
    exit 1
  fi
}

list_workspaces() {
  go run $HOME/bin/list_vscode_workspaces/cmd/list_workspaces/main.go "$@"
}

# handle_selection takes the selection from rofi and invokes VS Code with it
handle_selection() {
  local ws_path="$ROFI_INFO"
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
  # TODO: use ROFI_RETV to determine behavior.
  # https://davatorium.github.io/rofi/1.7.5/rofi-script.5/#rofi_retv

  # check if Go is available and display an error if not.
  if ! ensure_go; then
    exit 1
  fi

  # If there are no arugments, list workspaces in a format suitable for rofi.
  if (( $# == 0 )); then
    list_workspaces
    return
  fi

  handle_selection "$*" &
}

# the main entrypoint for the script
main() {
  if [[ "$ROFI_DATA" == FAIL ]]; then
    echo "ROFI_DATA is set to FAIL due to a previous error - giving up" >&2
  fi

  # if ROFI_RETV is set, then we're invoked from within rofi
  if [[ -v ROFI_RETV ]]; then
    rofi_main "$@"
    return
  fi

  # if ROFI_RETV is not set, try handling commands from the user
  case "$1" in
    ls|list)
      list_workspaces -plain
      return
      ;;
  esac

  # otherwise, if this was invoked from the CLI with no options, launch rofi and
  # tell it to use this script.
  rofi -show code -modi "code:$PROGNAME"
}
if [[ $ZSH_EVAL_CONTEXT == toplevel ]]; then
  PROGNAME="$0"
  main "$@"
fi