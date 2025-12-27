#!/usr/bin/env bash

## Uncomment this line to enable debug logging:
# AEROSPACE_SKETCHYBAR_DEBUG=1

# TODO: Try finding a good way to hide labels for workspaces that are inactive.
# I tried using label.drawing=off, but that adds weird amounts of space between
# the labels that are visible.

has_open_windows() {
  [[ "$has_open_windows" ]]
}

is_focused_workspace() {
  [[ "$is_focused_workspace" ]]
}

update_sketchybar() {
  # Set default properties for each attribute to be sure they're always set.
  # BEWARE: Make sure to add properties here.
  bg_drawing=off
  label_color=0xffdddddd
  label_font_style=Italic

  # TODO: For now, we include the focused workspace here, but ideally I'd like
  # to find a way leave the workspace label gray and italic until it has open
  # windows. However, since this script only gets run when the focused workspace
  # changes, it won't update the active workspace.
  if has_open_windows || is_focused_workspace; then
    # If the workspace has open windows, make its label white and bold.
    echo "Workspace $ws_name has open windows and/or is focused"
    label_color=0xffffffff
    label_font_style=Bold
  else
    # If the workspace has no open windows, make its label grey and italic.
    echo "Workspace $ws_name has no open windows and is not focused"
    label_color=0xffdddddd
    label_font_style=Italic
  fi

  if is_focused_workspace; then
    # Draw a background for the focused workspace item only.
    echo "Workspace $ws_name is focused"
    bg_drawing=on
  else
    echo "Workspace $ws_name is not focused"
    bg_drawing=off
  fi

  params=(
    background.drawing="$bg_drawing"
    label.color="$label_color"
    label.font.style="$label_font_style"
  )

  sketchybar --set "$NAME" "${params[@]}"
}

check_workspace_state() {
  # aerospace_active_workspaces.txt is updated by _update_active_workspaces.sh,
  # which should be invoked in exec-on-workspace-change and after-startup-command
  # in aerospace.toml.
  #
  # This file contains a list of workspace names in the format "ws:NAME" -- e.g.
  # "ws:1", "ws:2", etc. This allows us to uniquely match workspace names by
  # searching for "ws:$1" below.
  active_workspaces="$(</tmp/aerospace_active_workspaces.txt)"

  has_open_windows=
  if [[ "$active_workspaces" == *"ws:$ws_name"* ]]; then
    has_open_windows=1
  fi

  is_focused_workspace=
  # When sketchybar is restarted/reloaded, FOCUSED_WORKSPACE will be unset.
  # Checking the active workspaces file for the focused workspace lets us
  # highlight the focused workspace even in this scenario.
  if [[ "$ws_name" == "$FOCUSED_WORKSPACE" ]] || [[ "$active_workspaces" == *"focused:$ws_name"* ]]; then
    is_focused_workspace=1
  fi
}

main() {
  if [[ "$AEROSPACE_SKETCHYBAR_DEBUG" ]]; then
    exec >"/tmp/sketchybar_aerospace_plugin_$1.log" 2>&1
  fi

  echo "===== $(date) -- ws_name=$1 ====="
  set -x

  ws_name="$1"

  check_workspace_state
  update_sketchybar

  set +x
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi