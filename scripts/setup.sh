#!/usr/bin/env bash
set -euo pipefail

notice() {
  local message="= $1 ="
  local messagelen="${#message}"
  echo ""
  printf '=%.0s' $(seq 1 "$messagelen")
  echo ""
  echo "$message"
  printf '=%.0s' $(seq 1 "$messagelen")
  echo ""
  echo ""
}

info() {
  echo "$(tput setaf 2)** $*$(tput sgr0)" >&2
}

fatal() {
  echo "$(tput setaf 1)ERROR: $*$(tput sgr0)" >&2
  exit 1
}

[[ "$EUID" -eq 0 ]] || fatal "You must run this script as root."

USER=joe
TMP=/tmp/machine_setup
mkdir -p "$TMP"
cd "$TMP"

apt_packages=(
  vim
  keepassxc
  gnome-tweaks
  emacs
  apt-transport-https
  shellcheck
  spotify-client
  code
  steam
  i3
)

vscode_extensions=(
  dcasella.i3
  felipe-mendes.slack-theme
  jetmartin.bats
  mads-hartmann.bash-ide-vscode
  mark-hansen.hledger-vscode
  mshr-h.veriloghdl
  patbenatar.advanced-new-file
  samuelcolvin.jinjahtml
  stkb.rewrap
  timonwong.shellcheck
)

notice "Installing VS Code Repo"
# https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions
curl https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  > "$TMP/packages.microsoft.gpg"
sudo install -o root -g root -m 644 "$TMP/packages.microsoft.gpg" /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

notice "Installing Spotify repo"
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list


notice "Installing packages"
add-apt-repository multiverse
apt-get update
sudo apt install "${apt_packages[@]}"

notice "Installing VS Code Extensions"
for ext in "${vscode_extensions[@]}"; do
  sudo -u "$USER" code --install-extension "$ext"
done

notice "Installing hledger"