__FLATPAK_BIN=$HOME/.local/share/flatpak/exports/bin
if [[ -d $__FLATPAK_BIN ]]; then
  export PATH="$__FLATPAK_BIN:$PATH"
fi