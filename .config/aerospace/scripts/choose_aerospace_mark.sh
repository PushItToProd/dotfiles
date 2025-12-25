#!/usr/bin/env bash
# choose_aerospace_mark.sh allows picking a window from aerospace-marks.

PROGDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# shellcheck source=common.bash
source "$PROGDIR/common.bash"

PATH="$HOME/go/bin:$PATH"

list_marks() {
  # `aerospace-marks list` lists windows and marks in the following format:
  #     <mark>|<window-id>|<app-name>|<window-title>|<workspace>|<app-bundle-id>
  aerospace-marks list
}

main() {
  if ! command -v aerospace-marks &>/dev/null; then
    osascript -e ''
  fi

  aerospace_marks_str=$(list_marks)

  selection="$(choose -zp "Select a mark" -w 50 <<< "$aerospace_marks_str")"

  if [[ "$selection" == "" ]]; then
    # no selection - exit early
    return
  fi

  # parse the mark from the list
  IFS='|' read -r mark _ <<<"$selection"
  mark="$(trim_string "$mark")"

  aerospace-marks focus "$mark"
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi