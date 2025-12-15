#!/usr/bin/env bash

MAX_TITLE_LEN=20

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

trim_string() {
    # Usage: trim_string "   example   string    " (emits "example string")
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s\n' "$_"
}

truncate_str() {
  local str="$1"
  local maxlen="${2-$MAX_TITLE_LEN}"
  printf '%s' "$(trim_string "${str:0:$maxlen}")"
  if [[ "${#str}" -gt "$maxlen" ]]; then
    printf '%s' "..."
  fi
}

aerospace::list_workspace_windows() {
  aerospace list-windows --all --format $'%{workspace}\t%{app-name}\t%{window-title}' | sort | uniq
}

group_by_workspace() {
  if ! is_assoc_array "$1"; then
    fatal "$0 requires the name of an associative array variable as its first argument"
  fi
  local -n workspaces="$1"

  local workspace app_name win_title ws_windows app_label
  while IFS=$'\t' read -r workspace app_name win_title; do
    win_title="$(truncate_str "$win_title")"

    ws_windows="${workspaces["$workspace"]}"
    if [[ "$win_title" ]]; then
      app_label="$app_name ($win_title)"
    else
      app_label="$app_name"
    fi

    if [[ ! "$ws_windows" ]]; then
      # first time seeing this workspace -- add the app name to the start of the
      # list
      workspaces["$workspace"]="$app_label"
      continue
    fi

    workspaces["$workspace"]="$ws_windows, $app_label"
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