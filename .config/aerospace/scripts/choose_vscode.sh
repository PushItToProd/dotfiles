#!/usr/bin/env bash
# A script for easily opening recent VS Code workspaces using choose-gui on
# macOS.
#
# This is basically a reimplementation of rofi_code.zsh from my i3 setup.config/aerospace/aerospace.toml.

trim_string() {
    # Usage: trim_string "   example   string    " (emits "example string")
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s\n' "$_"
}

list_workspaces() {
  go run "$HOME"/bin/list_vscode_workspaces/cmd/list_workspaces/main.go --format choose
}

main() {
  vscode_workspaces_str="$(list_workspaces)"

  mapfile vscode_workspaces<<<"$vscode_workspaces_str"

  # remove the first field (window ID) from each displayed option
  display_text=$(sed 's/[^|]* \| //' <<<"$vscode_workspaces_str")

  selection="$(choose -izp "Select a VS Code workspace" <<< "$display_text")"
  if [[ "$selection" == -1 ]]; then
    # no selection - exit early
    return
  fi

  IFS='|' read -r selected_workspace _ <<<"${vscode_workspaces["$selection"]}"
  selected_workspace="$(trim_string "$selected_workspace")"

  if [[ ! "$selected_workspace" ]]; then
    echo "error: no workspace selected" >&2
    exit 1
  fi

  echo "Selection: $selected_workspace"
  code -n "$selected_workspace"
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi