#!/usr/bin/env bash

: <<'HOWTOINCLUDE'
PROGDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# shellcheck source=common.bash
source "$PROGDIR/common.bash"
HOWTOINCLUDE

: "${ACTIVE_WORKSPACES_FILE="/tmp/aerospace_active_workspaces.txt"}"

trim_string() {
    # Usage: trim_string "   example   string    " (emits "example string")
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s\n' "$_"
}

remove_first_field_from_lines() {
  sed 's/[^|]* \| //'
}

error() {
  printf 'error: %s\n' "$*" >&2
}

fatal() {
  printf 'fatal: %s\n' "$*" >&2
  exit 1
}

is_assoc_array() {
  local -n __is_assoc_array__var="$1"
  [[ "${__is_assoc_array__var@a}" == *A* ]]
}

truncate_str() {
  local str="$1"
  local maxlen="$2"
  printf '%s' "$(trim_string "${str:0:$maxlen}")"
  if [[ "${#str}" -gt "$maxlen" ]]; then
    printf '%s' "..."
  fi
}
