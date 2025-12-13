#!/usr/bin/env bash

trim_string() {
    # Usage: trim_string "   example   string    "
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s\n' "$_"
}

main() {
  selection="$(aerospace list-windows --workspace visible --format '%{window-id}%{right-padding} | %{app-name}%{right-padding} | %{window-title}' | choose)"

  IFS='|' read -r window_id _app_name _app_title <<<"$selection"

  window_id="$(trim_string "$window_id")"

  aerospace focus --window-id "$window_id"
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi