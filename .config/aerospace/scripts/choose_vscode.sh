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

extract_ssh_remote_hostname() {
  local selection="$1"
  selection="$(trim_string "$1")"
  # strip `[ssh-remote:` prefix
  selection="${selection#\[ssh-remote:}"
  # strip `]` suffix
  selection="${selection%%\]*}"
  printf '%s' "$selection"
}

main() {
  vscode_workspaces_str="$(list_workspaces)"
  # Store the original entries in an array so we can look them up.
  mapfile vscode_workspaces<<<"$vscode_workspaces_str"

  # Remove the first field (window ID) from each displayed option. Later, we'll
  # look up the original value using the vscode_workspaces array created above.
  display_text=$(remove_first_field_from_lines <<<"$vscode_workspaces_str")

  # Prompt the user for input and return the index of their selection.
  selection="$(choose -izp "Select a VS Code workspace" -w 50 -n 20 <<<"$display_text")"
  declare -p selection
  if [[ "$selection" == -1 ]]; then
    # no selection - exit early
    return
  fi

  # Using the index returned by `choose`, look up the original raw workspace
  # entry from the vscode_workspaces array.
  raw_entry="${vscode_workspaces["$selection"]}"
  declare -p raw_entry
  IFS='|' read -r selected_workspace _ <<<"$raw_entry"
  selected_workspace="$(trim_string "$selected_workspace")"
  declare -p selected_workspace

  if [[ ! "$selected_workspace" ]]; then
    echo "error: no workspace selected" >&2
    exit 1
  fi

  echo "Selection: $selected_workspace"

  # Check if this is a remote-only entry (marked with REMOTE_ONLY)
  if [[ "${vscode_workspaces["$selection"]}" == *"REMOTE_ONLY"* ]]; then
    # Extract the hostname from the friendly path format [ssh-remote:hostname]
    # The workspace field contains the original vscode-remote URI
    IFS='|' read -r _ selected_friendly_path <<<"${vscode_workspaces["$selection"]}"

    # Extract hostname from format like "[ssh-remote:hostname] (REMOTE_ONLY)" using string manipulation
    hostname="$(extract_ssh_remote_hostname "$selected_friendly_path")"
    if [[ -z "$hostname" ]]; then
      echo "error: could not parse hostname from friendly path: $selected_friendly_path" >&2
      exit 1
    fi

    echo "Opening SSH remote: $hostname"
    code -n --remote "ssh-remote+$hostname"
  else
    # To open remote workspaces with paths, we need to use the --folder-uri flag.
    code --new-window --folder-uri "$selected_workspace"
  fi
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi