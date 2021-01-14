### Trilium ###

notice "Installing Trilium"

# trilium_url='https://github.com/zadam/trilium/releases/download/v0.43.4/trilium-linux-x64-0.43.4.tar.xz'
trilium_url='https://github.com/zadam/trilium/releases/download/v0.45.8/trilium-linux-x64-0.45.8.tar.xz'
trilium_tar="$(basename "$trilium_url")"
trilium_dirname='trilium-linux-x64'
trilium_install_dir="$APPDIR/$trilium_dirname"

: "${SETUP_SH_FORCE_INSTALL_TRILIUM:=}"

if [[ "$SETUP_SH_FORCE_INSTALL_TRILIUM" != "" ]]; then
  info "SETUP_SH_FORCE_INSTALL_TRILLIUM is set - trilium will be force-installed"
  if [[ -d "$trilium_install_dir" ]]; then
    trilium_backup_install_dir="$trilium_install_dir.bak$(date -Iminutes)"
    info "The trilium intall directory $trilium_install_dir already exists. Backing up to $trilium_backup_install_dir"
    mv "$trilium_install_dir" "$trilium_backup_install_dir"
  fi
fi

if [[ -d "$trilium_install_dir" ]]; then
  info 'Trilium is already installed'
else
  info 'Installing Trilium'
  wget "$trilium_url"
  tar -xf "$trilium_tar"
  mv -f "$trilium_dirname" "$APPDIR"
fi