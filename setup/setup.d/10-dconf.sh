### Basic OS Config ###
notice "Applying basic settings"

info "Mapping capslock to escape"
dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape']"

info "Configuring gnome-terminal bindings"
dconf write /org/gnome/terminal/legacy/keybindings/prev-tab "'<Alt>comma'"
dconf write /org/gnome/terminal/legacy/keybindings/next-tab "'<Alt>period'"
dconf write /org/gnome/terminal/legacy/keybindings/move-tab-left "'<Alt>less'"
dconf write /org/gnome/terminal/legacy/keybindings/move-tab-right "'<Alt>greater'"