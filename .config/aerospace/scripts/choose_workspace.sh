#!/usr/bin/env bash

FIELDS=(
  'workspace'
  'app-name'
)

fatal() {
  printf '%s\n' "$*" >&2
  exit 1
}

is_assoc_array() {
  local -n __is_assoc_array__var="$1"
  [[ "${__is_assoc_array__var@a}" == *A* ]]
}

aerospace::list_workspace_windows() {
  aerospace list-windows --all --format $'%{workspace}\t%{app-name}' | sort
}

group_by_workspace() {
  if ! is_assoc_array "$1"; then
    fatal "$0 requires the name of an associative array variable as its first argument"
  fi
  local -n workspaces="$1"

  local workspace app_name windows
  while IFS=$'\t' read -r workspace app_name; do
    windows="${workspaces["$workspace"]}"
    if [[ ! "$windows" ]]; then
      # first time seeing this workspace -- add the app name to the start of the
      # list
      workspaces["$workspace"]="$app_name"
      continue
    fi

    # Add app_name to the list if it's not already present. (Edge case: if
    # there's already an app whose name is a substring of app_name, it won't get
    # added to the list.)
    if [[ "$windows" != *"$app_name"* ]]; then
      workspaces["$workspace"]="$windows, $app_name"
    fi
  done  # reads from stdin
}

main() {
  shopt -s lastpipe

  declare -A workspace_windows
  aerospace::list_workspace_windows | group_by_workspace workspace_windows

  local ws apps
  for ws in "${!workspace_windows[@]}"; do
    apps="${workspace_windows["$ws"]}"
    printf '%s | %s\n' "$ws" "$apps"
  done | sort

  # TODO: pipe to choose-gui and allow picking
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi