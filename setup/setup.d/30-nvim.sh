

if [[ ! -f "$BINDIR/nvim" ]]; then
  as_me curl --location \
    --output "$BINDIR/nvim" \
    https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
fi

chmod u+x "$BINDIR/nvim"
