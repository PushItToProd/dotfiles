#!/usr/bin/env bash

# TODO: work out how to make this highlight the correct workspace when I run
# `sketchybar --reload`. Currently, it leads to no space being highlighted since
# AEROSPACE_FOCUSED_WORKSPACE (and, thus, FOCUSED_WORKSPACE) is unset.

# aerospace_active_workspaces.txt is updated by _update_active_workspaces.sh,
# which should be invoked in exec-on-workspace-change and after-startup-command
# in aerospace.toml.
#
# This file contains a list of workspace names in the format "ws:NAME" -- e.g.
# "ws:1", "ws:2", etc. This allows us to uniquely match workspace names by
# searching for "ws:$1" below.
active_workspaces="$(</tmp/aerospace_active_workspaces.txt)"

# Beware: if you set any properties in any of these branches, you have to set
# them in all branches or they'll be permanently applied to the label until
# sketchybar restarts.
if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set "$NAME" background.drawing=on label.color=0xffffffff label.font.style=Bold
elif [[ "$active_workspaces" == *"ws:$1"* ]]; then
    # If the given workspace is in the list of active workspaces (i.e. it has
    # open windows), make it white and bold.
    sketchybar --set "$NAME" background.drawing=off label.color=0xffffffff label.font.style=Bold
else
    # Make non-active workspaces (no windows) gray and italic.
    sketchybar --set "$NAME" background.drawing=off label.color=0xffdddddd label.font.style=Italic
fi
