#!/usr/bin/env bash

i3-msg -t get_marks | jq -r '.[]' | while read -r mark; do
  echo -n "$mark --- "
  bash ~/.config/i3/scripts/get_marked.sh "$mark"
done