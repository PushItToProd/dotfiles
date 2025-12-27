#!/usr/bin/env bash
# Persist a list of active workspaces that can be queried by my aerospace plugin
# for sketchybar.

PROGDIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# shellcheck source=common.bash
source "$PROGDIR/common.bash"

{
  echo "Last update: $(date -Iseconds)"
  printf 'focused:%s\n' "$(aerospace list-workspaces --focused)"
  # Print workspace names with a distinct prefix in case any workspace name is
  # a substring of a different workspace name.
  aerospace list-windows --all --format 'ws:%{workspace}' | sort | uniq
} >"$ACTIVE_WORKSPACES_FILE"
