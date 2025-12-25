#!/usr/bin/env bash
# Persist a list of active workspaces that can be queried by my aerospace plugin
# for sketchybar.

{
  echo "Last update: $(date -Iseconds)"
  # Print workspace names with a distinct prefix in case any workspace name is
  # a substring of a different workspace name.
  aerospace list-windows --all --format 'ws:%{workspace}' | sort | uniq
} >/tmp/aerospace_active_workspaces.txt
