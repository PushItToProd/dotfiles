#!/usr/bin/env bash
# If an iTerm window is focused, open a new tab. Otherwise, open a new window.

# TODO: accept a command to run as an argument

osascript -e '
tell application "iTerm2"
  if frontmost then
    tell current window to create tab with default profile
  else
    create window with default profile
  end if
end tell
'