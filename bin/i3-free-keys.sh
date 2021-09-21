#!/usr/bin/env bash

I3_CONFIG="$HOME/.config/regolith/i3/config"

for ch in {a..z}; do
  if ! grep '^bindsym \$mod+'"$ch" "$I3_CONFIG"; then
    echo "  $(tput setaf 2)\$mod+$ch is available!$(tput sgr0)"
  fi
done