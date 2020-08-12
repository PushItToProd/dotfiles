#!/usr/bin/env bash

apt_packages+=(code)

vscode_extensions=(
  dcasella.i3
  felipe-mendes.slack-theme
  jetmartin.bats
  mads-hartmann.bash-ide-vscode
  mark-hansen.hledger-vscode
  mshr-h.veriloghdl
  dkundel.vscode-new-file
  samuelcolvin.jinjahtml
  stkb.rewrap
  timonwong.shellcheck
)

install_vscode_repo() {
  notice "Installing VS Code Repo"
  # https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions
  curl https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    > "$TMP/packages.microsoft.gpg"
  sudo install -o root -g root -m 644 \
    "$TMP/packages.microsoft.gpg" /etc/apt/trusted.gpg.d/
  echo "deb [arch=amd64" \
    "signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg]" \
    "https://packages.microsoft.com/repos/vscode stable main" \
    > /etc/apt/sources.list.d/vscode.list
}

install_vscode_extensions() {
  notice "Installing VS Code Extensions"
  for ext in "${vscode_extensions[@]}"; do
    sudo -u "$USER" code --install-extension "$ext"
  done
}

pre_install_tasks+=(install_vscode_repo)
post_install_tasks+=(install_vscode_extensions)