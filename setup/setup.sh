#!/usr/bin/env bash
set -euo pipefail

readonly PROGNAME="$(basename "$0")"
readonly DIR="$(dirname "$(readlink -f "$0")")"

source "$DIR/messages.sh"

apt_repos=(
  multiverse
  ppa:regolith-linux/release
)

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
  libtinfo-dev  # hledger
  libgmp-dev    # hledger
  pavucontrol
  gdebi-core    # discord
  wget
  python3-pip

  # i3 support functionality
  blueman       # provides blueman-applet for bluetooth control from taskbar
  gnome-settings-daemon
  numlockx
  fcitx-bin     # japanese support
  rofi

  # rofimoji dependencies
  fonts-emojione
  python3
  xdotool
  xsel

  # regolith
  regolith-desktop
  i3xrocks-net-traffic
  i3xrocks-cpu-usage
  i3xrocks-time
  i3xrocks-memory
  i3xrocks-battery
  i3xrocks-volume
  i3xrocks-temp
  i3xrocks-media-player
  i3-gaps-wm
  regolith-gnome-flashback
  regolith-i3-gaps-config
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
  vscodevim.vim
)

[[ "$EUID" -eq 0 ]] || fatal "You must run this script as root."

USER=joe
TMP=/tmp/machine_setup
mkdir -p "$TMP"
cd "$TMP"


### Basic OS Config ###
notice "Applying basic settings"

info "Mapping capslock to escape"
dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape']"


### VS Code Repo ###

notice "Installing VS Code Repo"
# https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions
curl https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  > "$TMP/packages.microsoft.gpg"
install -o root -g root -m 644 "$TMP/packages.microsoft.gpg" /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list


### Spotify Repo ###

notice "Installing Spotify repo"
curl -sS https://download.spotify.com/debian/pubkey.gpg | apt-key add -
echo "deb http://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list


### Install ###

notice "Setting up repos"
for repo in "${apt_repos[@]}"; do
  add-apt-repository -y "$repo"
done

notice "Installing packages"

info "apt-get update"
apt-get update

info "fixing broken installs"
apt --fix-broken install

info "installing packages"
apt install "${apt_packages[@]}"


### VS Code Extensions ###

notice "Installing VS Code Extensions"
for ext in "${vscode_extensions[@]}"; do
  sudo -u "$USER" code --install-extension "$ext"
done


### Install Hledger ###

if ! which hledger &>/dev/null; then
  notice "Installing hledger"
  sudo -u "$USER" bash /home/$USER/bin/hledger-install.sh
fi


### Install Discord ###

notice "Installing Discord"
wget -O "$TMP/discord.deb" "https://discordapp.com/api/download?platform=linux&format=deb"
dpkg -i "$TMP/discord.deb" || {
  info "Initial Discord install failed. Trying to grab dependencies"
  apt-get -f --force-yes --yes install
  dpkg -i "$TMP/discord.deb"
}

### Install Rofimoji ###

notice "Installing Rofimoji for i3"

# Package URL, filename, and download location
rofimoji_url='https://github.com/fdw/rofimoji/releases/download/4.2.0/rofimoji-4.2.0-py3-none-any.whl'
rofimoji_package="$(basename "$rofimoji_url")"
rofimoji="$TMP/$rofimoji_package"

# Download the package
wget -O "$rofimoji" https://github.com/fdw/rofimoji/releases/download/4.2.0/rofimoji-4.2.0-py3-none-any.whl

# Install rofimoji. --no-warn-script-location is here because ~/.local/bin isn't
# on the path for the root user.
sudo -u "$USER" pip3 install --user --no-warn-script-location "$rofimoji"

### Install Virtualenv ###
notice "Installing Virtualenv"
sudo -u "$USER" pip3 install virtualenv

# TODO: trilium
# TODO: my pomodoro timer