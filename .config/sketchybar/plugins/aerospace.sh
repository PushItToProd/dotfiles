#!/usr/bin/env bash

# TODO: work out how to make this highlight the correct workspace when I run
# `sketchybar --reload`. Currently, it leads to no space being highlighted since
# AEROSPACE_FOCUSED_WORKSPACE (and, thus, FOCUSED_WORKSPACE) is unset.

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" background.drawing=on
else
    sketchybar --set "$NAME" background.drawing=off
fi
