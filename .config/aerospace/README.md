# My AeroSpace config

- `aerospace.toml` - main AeroSpace config
- `scripts/` contains helper scripts meant to be called from AeroSpace bindings.
  - `_update_active_workspaces.sh` - invoked at AeroSpace startup and when 
  - `common.bash`
- `utils/` contains other scripts (well, currently, _a_ script) not meant to be called directly from AeroSpace. Namely, `generate_marks_mode.py` programmatically generates some TOML for setting and navigating to marks using a single keystroke.

## Dependencies

Hard dependencies

- AeroSpace - an awesome tiling window manager for macOS
- aerospace-marks - emulation of i3's vim-style marks
- choose-gui - analogue of Rofi (a scriptable popup menu/navigation thing) but for macOS
- Sketchybar - scriptable replacement for the macOS menu bar, used to show an i3-style workspace list at the top of the screen

Soft dependencies

- SwipeAeroSpace - allows navigating AeroSpace workspaces using three-finger swipe gestures
- Karabiner - used to bind caps lock and backslash to ctrl+cmd+alt (which I call "semihyper")
