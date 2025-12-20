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
    "$@" \
    --format '%{window-id}%{right-padding} | %{workspace}%{right-padding} | %{app-name}%{right-padding} | %{window-title}' \
    | sort --field-separator='|' --ignore-leading-blanks --sort=numeric --key=2
}

remove_first_field_from_lines() {
  sed 's/[^|]* \| //'
}

main() {
  aerospace_windows_str=$(list_windows --all)

  # copy window list to an array so we can look up windows by selection index
  mapfile aerospace_windows <<<"$aerospace_windows_str"

  # remove the first field (window ID) from each displayed option
  display_text=$(remove_first_field_from_lines <<<"$aerospace_windows_str")

  # get the selection index
  selection="$(choose -izp "Select a window (all workspaces)" <<< "$display_text")"
  # echo "selected: ${aerospace_windows["$selection"]}"

  # a selection of -1 means the user hit escape or otherwise exited without
  # picking an option -> do nothing
  if [[ "$selection" == -1 ]]; then
    return
  fi

  # parse the window_id from the selection and trim surrounding spaces
  IFS='|' read -r window_id _ <<<"${aerospace_windows["$selection"]}"
  window_id="$(trim_string "$window_id")"

  # finally, we can switch to the given window
  aerospace focus --window-id "$window_id"
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
