

as_me curl --location \
  --output "$BINDIR/nvim" \
  https://github.com/neovim/neovim/releases/latest/download/nvim.appimage

chmod u+x "$BINDIR/nvim"
