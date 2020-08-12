#!/usr/bin/env bash
set -euo pipefail

readonly PROGNAME="$(basename "$0")"
readonly DIR="$(dirname "$(readlink -f "$0")")"

source "$DIR/messages.sh"

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
  libtinfo-dev  # hledger
  libgmp-dev    # hledger
  pavucontrol
  gdebi-core    # discord
  wget
)

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

[[ "$EUID" -eq 0 ]] || fatal "You must run this script as root."

USER=joe
TMP=/tmp/machine_setup
mkdir -p "$TMP"
cd "$TMP"

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

if ! which hledger &>/dev/null; then
  notice "Installing hledger"
  sudo -u "$USER" bash /home/$USER/bin/hledger-install.sh
fi

notice "Installing Discord"
wget -O "$TMP/discord.deb" "https://discordapp.com/api/download?platform=linux&format=deb"
gdebi "$TMP/discord.deb"
