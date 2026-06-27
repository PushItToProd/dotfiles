#!/usr/bin/env bash
# A script for easily opening recent VS Code workspaces using choose-gui on
# macOS.
#
# This is basically a reimplementation of rofi_code.zsh from my i3 setup.

PROGDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# shellcheck source=common.bash
source "$PROGDIR/common.bash"

list_workspaces() {
  go run "$HOME"/bin/list_vscode_workspaces/cmd/list_workspaces/main.go --format choose
}

# Load and preprocess the list of VS Code workspaces and remotes into
# workspaces_display_str (a string for display to the user via `choose`) and
# vscode_workspaces (an array we can use to look up the original output).
#
# Globals:
#   * vscode_workspaces
#   * workspaces_choose_list
load_workspaces() {
  local vscode_workspaces_str    # raw output from list_workspaces
  vscode_workspaces_str="$(list_workspaces)"

  # Store the original entries in an array so we can look them up.
  mapfile vscode_workspaces<<<"$vscode_workspaces_str"

  # Remove the first field (the raw VS Code URI) from each displayed option.
  # Later, we'll look up the original value using the vscode_workspaces array
  # created above.
  workspaces_choose_list=$(remove_first_field_from_lines <<<"$vscode_workspaces_str")
}

# With `--format choose`, the output of list_workspaces is a newline-delimited
# list of entries comprised of the raw path/URI used to access the remote, a
# pipe delimiter surrounded by spaces, and a user-friendly display string. For
# example:
#
#     /home/user/foo | ~/foo
#     vscode-remote://ssh-remote+HOSTNAME/blah | [ssh-remote:HOSTNAME] /blah
#
# parse_workspace_entry parses an entry of this format, splitting the input on
# pipe delimiters and trimming whitespace from each item, and populating the
# results into the globals listed below.
#
# Globals:
#   * selected_workspace
#   * selected_friendly_path
parse_workspace_entry() {
  IFS='|' read -r selected_workspace selected_friendly_path
  selected_workspace="$(trim_string "$selected_workspace")"
  selected_friendly_path="$(trim_string "$selected_friendly_path")"
}

handle_selection() {
  local selected_workspace="$1"
  local selected_friendly_path="$2"

  # Check if this is a remote-only entry (marked with REMOTE_ONLY)
  if [[ "$selected_friendly_path" == *"REMOTE_ONLY"* || "$selected_workspace" != */* ]]; then
    # To open an SSH remote standalone without a workspace or folder, we must
    # use the --remote flag.
    code -n --remote "$selected_workspace"
  else
    # To open remote workspaces with paths, we need to use the --folder-uri
    # flag.
    code --new-window --folder-uri "$selected_workspace"
  fi
}

vscode_choose_prompt="Select a VS Code workspace"
vscode_choose_width=50
vscode_choose_rows=20

get_user_selection() {
  local selection_idx
  selection_idx="$(
    choose -iz \
      -p "$vscode_choose_prompt" \
      -w "$vscode_choose_width" \
      -n "$vscode_choose_rows" \
      <<<"$workspaces_choose_list"
  )"
  if [[ "$selection_idx" == -1 ]]; then
    # no selection - exit early
    return
  fi
  printf '%s' "${vscode_workspaces["$selection_idx"]}"
}

main() {
  local -a vscode_workspaces     # Array of entries from vscode_workspaces_str
  local workspaces_choose_list   # List of entries for display via `choose`
  # Populate vscode_workspaces and workspaces_choose_list.
  load_workspaces

  # Prompt the user for input and return the index of their selection.
  local selected_ws_entry
  selected_ws_entry="$(get_user_selection)"

  # Using the index returned by `choose`, look up the original raw workspace
  # entry from the vscode_workspaces array.
  local selected_workspace
  local selected_friendly_path
  parse_workspace_entry <<<"$selected_ws_entry"
  if [[ ! "$selected_workspace" ]]; then
    fatal "no workspace selected"
  fi
  echo "Selection: $selected_workspace"
  echo "Friendly path: $selected_friendly_path"

  handle_selection "$selected_workspace" "$selected_friendly_path"
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi