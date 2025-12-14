#!/usr/bin/env bash
# choose_window.sh uses choose-gui to display a list of windows open in the
# current AeroSpace workspace. The selected window is then focused.

trim_string() {
    # Usage: trim_string "   example   string    " (emits "example string")
    : "${1#"${1%%[![:space:]]*}"}"
    : "${_%"${_##*[![:space:]]}"}"
    printf '%s\n' "$_"
}

list_windows() {
  # The --format argument here is the default value used by aerospace, but we
  # specify it explicitly in case they ever change it.
  aerospace list-windows \
    --workspace visible \
    --format '%{window-id}%{right-padding} | %{app-name}%{right-padding} | %{window-title}'
}

main() {
  selection="$(list_windows | choose)"

  IFS='|' read -r window_id _ <<<"$selection"

  # AeroSpace will throw an error if we include any surrounding spaces in
  # $window_id.
  window_id="$(trim_string "$window_id")"
  aerospace focus --window-id "$window_id"
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
