__FLATPAK_BIN=$HOME/.local/share/flatpak/exports/bin
if [[ -d $__FLATPAK_BIN ]]; then
  path=($__FLATPAK_BIN $path)
fi
