#!/usr/bin/env bash
# Get the name of container with the given mark

if [[ "$1" == "" ]]; then
  echo "error: must provide a mark" >&2
  exit 1
fi

gen_cmd() {
  printf '.. | select(.marks? | index("%s")).name' "$1"
}

cmd="$(gen_cmd "$1")"

i3-msg -t get_tree | jq -r "$cmd"