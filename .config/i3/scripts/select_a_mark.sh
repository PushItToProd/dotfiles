#!/usr/bin/env bash

# by default we use the mark to determine what to focus
cmd='[con_mark="%s"] focus'
if [[ "$1" ]]; then
  cmd="$1"
fi

prompt='Select a mark'
if [[ "$2" ]]; then
  prompt="$2"
fi


get_marked() {
  bash ~/.config/i3/scripts/get_marked.sh "$1"
}

display_menu() {
  i3-msg -t get_marks | jq -r '.[]' | sort | while read -r mark; do
    echo "$mark --- $(get_marked "$mark")"
  done | rofi -dmenu -i -p "$prompt"
}

selection="$(display_menu)"

if [[ ! "$selection" ]]; then
  echo "no selection" >&2
  exit 1
fi

echo "selected: $selection" >&2
mark="${selection%% --- *}"
echo "selected mark: $mark" >&2

i3-msg "$(printf "$cmd" "$mark")"