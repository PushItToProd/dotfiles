#!/usr/bin/env bash

get_marked() {
  bash ~/.config/i3/scripts/get_marked.sh "$1"
}

display_menu() {
  i3-msg -t get_marks | jq -r '.[]' | sort | while read -r mark; do
    echo "$mark --- $(get_marked "$mark")"
  done | rofi -dmenu -i -p "Select a mark"
}

selection="$(display_menu)"

if [[ ! "$selection" ]]; then
  echo "no selection" >&2
  exit 1
fi

echo "selected: $selection" >&2
mark="${selection%% --- *}"
echo "selected mark: $mark" >&2

i3-msg "$(printf '[con_mark="%s"] focus' "$mark")"