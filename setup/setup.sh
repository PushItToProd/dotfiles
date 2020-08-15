#!/usr/bin/env bash
set -euo pipefail

readonly PROGNAME="$(basename "$0")"
readonly PROGDIR="$(dirname "$(readlink -f "$0")")"

# shellcheck source=messages.sh
source "$PROGDIR/messages.sh"

# shellcheck source=install-deb.sh
source "$PROGDIR/install-deb.sh"

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
  vlc
  ffmpeg        # bitwig
  xclip
  python3-venv

  # i3 support functionality
  blueman       # provides blueman-applet for bluetooth control from taskbar
  gnome-settings-daemon
  numlockx
  fcitx-bin     # japanese support
  rofi
  jq

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

  # zsh
  zsh
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

appdir_name="Applications"
homedir_dirs=(
  bin
  "$appdir_name"
  Code/projects
)

declare -A homedir_repos=(
  ["Code/projects/hledger-shell"]="ssh://git@gitlab.zane.cloud:30001/joe/hledger-shell.git"
  ["Documents/ledger"]="ssh://git@gitlab.zane.cloud:30001/joe/ledger.git"
  ["Code/projects/my-hledger"]="git@github.com-pushittoprod:PushItToProd/my-hledger.git"
)

[[ "$EUID" -eq 0 ]] || fatal "You must run this script as root."

USER=joe
USER_HOME=/home/$USER
APPDIR="$USER_HOME/$appdir_name"

notice "Setting up homedir"

### Make sure git submodule dependencies are provided in homedir ###
cd "$USER_HOME"
if [[ ! -d .ssh ]]; then
  fatal "ssh keys need to be set up first"
fi

info "Updating Git submodules in homedir"
sudo -u "$USER" bash -c 'cd ~; git submodule init; git submodule update'

info "Creating home directories: ${homedir_dirs[*]}"
sudo -u "$USER" mkdir -p "${homedir_dirs[@]}"

info "Cloning repos"
for path in "${!homedir_repos[@]}"; do
  repo="${homedir_repos["$path"]}"
  info "Cloning $repo to $path"
  if [[ ! -d "$path" ]]; then
    sudo -u "$USER" git clone "$repo" "$path"
  fi
done


# Create temp directory for setup files
TMP=/tmp/machine_setup
mkdir -p "$TMP"
cd "$TMP"

### Basic OS Config ###
notice "Applying basic settings"

info "Mapping capslock to escape"
dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:escape']"

info "Configuring gnome-terminal bindings"
dconf write /org/gnome/terminal/legacy/keybindings/prev-tab "'<Alt>comma'"
dconf write /org/gnome/terminal/legacy/keybindings/next-tab "'<Alt>period'"
dconf write /org/gnome/terminal/legacy/keybindings/move-tab-left "'<Alt>less'"
dconf write /org/gnome/terminal/legacy/keybindings/move-tab-right "'<Alt>greater'"



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


################################
##### Install Apt Packages #####
################################

notice "Setting up apt repos"
for repo in "${apt_repos[@]}"; do
  add-apt-repository -y "$repo"
done

notice "Installing apt packages"

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

discord_url="https://discordapp.com/api/download?platform=linux&format=deb"
discord_filename=discord.deb
install_deb --url "$discord_url" --file "$discord_filename" --name discord

### Install Rofimoji ###

notice "Installing Rofimoji for i3"

if sudo -u "$USER" pip3 show rofimoji >/dev/null; then
  info "rofimoji is already installed"
else
  # Package URL, filename, and download location
  rofimoji_url='https://github.com/fdw/rofimoji/releases/download/4.2.0/rofimoji-4.2.0-py3-none-any.whl'
  rofimoji_package="$(basename "$rofimoji_url")"
  rofimoji="$TMP/$rofimoji_package"

  # Download the package
  wget -O "$rofimoji" https://github.com/fdw/rofimoji/releases/download/4.2.0/rofimoji-4.2.0-py3-none-any.whl

  # Install rofimoji. --no-warn-script-location is here because ~/.local/bin isn't
  # on the path for the root user.
  sudo -u "$USER" pip3 install --user --no-warn-script-location "$rofimoji"
fi

### Install Syncplay ###
notice "Installing Syncplay"
syncplay_url='https://github.com/Syncplay/syncplay/releases/download/v1.6.5/Syncplay-1.6.5-x86_64.AppImage'
syncplay="$APPDIR/Syncplay"
if [[ ! -f "$syncplay" ]]; then
  wget -O "$syncplay" "$syncplay_url"
fi
chmod +x "$syncplay"

### Install TeamSpeak ###
# shellcheck source=install-teamspeak.sh
source "$PROGDIR/install-teamspeak.sh"
install_teamspeak

### Install Synology Drive ###

notice "Installing Synology Drive"
synology_drive_url='https://global.download.synology.com/download/Tools/SynologyDriveClient/2.0.2-11078/Ubuntu/Installer/x86_64/synology-drive-client-11078.x86_64.deb'
install_deb --url "$synology_drive_url" --name synology-drive

### Install Bitwig ###

notice "Installing Bitwig"
bitwig_url='https://downloads.bitwig.com/stable/3.2.7/bitwig-studio-3.2.7.deb'
install_deb --url "$bitwig_url" --name bitwig-studio

### Install Powerline Shell ###
notice "Installing Powerline Shell"
sudo -u "$USER" pip3 install powerline-shell

### Use Zsh ###
notice "Switching to zsh"
chsh -s /usr/bin/zsh

# TODO: trilium
# TODO: my pomodoro timer
