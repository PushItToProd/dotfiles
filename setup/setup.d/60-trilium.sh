### Trilium ###
notice "Installing Trilium"
trilium_url='https://github.com/zadam/trilium/releases/download/v0.43.4/trilium-linux-x64-0.43.4.tar.xz'
trilium_tar="$(basename "$trilium_url")"
trilium_dirname='trilium-linux-x64'

if [[ -d "$APPDIR/$trilium_dirname" ]]; then
  info 'Trilium is already installed'
else
  info 'Installing Trilium'
  wget "$trilium_url"
  tar -xf "$trilium_tar"
  mv -f "$trilium_dirname" "$APPDIR"
fi