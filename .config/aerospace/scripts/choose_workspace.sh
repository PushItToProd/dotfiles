#!/usr/bin/env bash

MAX_TITLE_LEN=20

# IGNORE_TITLES specifies window titles that should not be returned
declare -A IGNORE_TITLES
IGNORE_TITLES=(
  ["-zsh"]=1
  ["bash"]=1
  ["Mozilla Firefox"]=1
)

# HIDE_APP_TITLES specifies the names of applications for which titles should
# not be displayed
declare -A HIDE_APP_TITLES
HIDE_APP_TITLES=(
  ["Activity Monitor"]=1
  ["KeePassXC"]=1
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

_generate_app_label() {
  local app_name="$1" win_title="$2"
  printf %s "$app_name"

  # skip apps configured not to display titles
  if [[ "${HIDE_APP_TITLES["$app_name"]}" ]]; then
    return
  fi

  win_title="$(truncate_str "$win_title")"
  if [[ "${IGNORE_TITLES["$win_title"]}" ]]; then
    return
  fi

  if [[ "$win_title" ]]; then
    printf %s " ($win_title)"
  fi
}

group_by_workspace() {
  if ! is_assoc_array "$1"; then
    fatal "$0 requires the name of an associative array variable as its first argument"
  fi
  local -n workspaces="$1"

  local workspace app_name win_title ws_windows app_label
  while IFS=$'\t' read -r workspace app_name win_title; do
    ws_windows="${workspaces["$workspace"]}"
    app_label="$(_generate_app_label "$app_name" "$win_title")"

    if [[ ! "$ws_windows" ]]; then
      # first time seeing this workspace -- add the app name to the start of the
      # list
      workspaces["$workspace"]="$app_label"
      continue
    fi

    workspaces["$workspace"]="$ws_windows, $app_label"
  done  # reads from stdin
}

list_all_workspace_windows() {
  declare -A workspace_windows
  aerospace::list_workspace_windows | group_by_workspace workspace_windows

  local ws apps
  for ws in "${!workspace_windows[@]}"; do
    apps="${workspace_windows["$ws"]}"
    printf '%s | %s\n' "$ws" "$apps"
  done | sort
}

main() {
  shopt -s lastpipe

  if [[ "$1" == list ]]; then
    list_all_workspace_windows
    return
  fi

  selection="$(list_all_workspace_windows | choose)"
  IFS=$'|' read -r workspace_id _ <<<"$selection"
  workspace_id=$(trim_string "$workspace_id")

  if [[ "$1" == test ]]; then
    echo "You selected: '$workspace_id'"
    return
  fi

  if [[ ! "$workspace_id" ]]; then
    return
  fi

  aerospace workspace "$workspace_id"
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi