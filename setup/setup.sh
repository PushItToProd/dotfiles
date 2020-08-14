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
  vlc
  ffmpeg        # bitwig

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
  # TODO: install powerline shell
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


### Install Syncplay ###
notice "Installing Syncplay"
syncplay_url='https://github.com/Syncplay/syncplay/releases/download/v1.6.5/Syncplay-1.6.5-x86_64.AppImage'
syncplay="$APPDIR/Syncplay"
wget -O "$syncplay" "$syncplay_url"
chmod +x "$syncplay"

### Install TeamSpeak ###
notice "Installing Teamspeak"
teamspeak_url='https://files.teamspeak-services.com/releases/client/3.5.3/TeamSpeak3-Client-linux_amd64-3.5.3.run'
teamspeak_installer="$APPDIR/$(basename "$teamspeak_url")"
teamspeak="$APPDIR/teamspeak"
teamspeak_dir=
if [ ! -f "$teamspeak_installer" ]; then
  info "Downloading teamspeak"
  wget -O "$teamspeak_installer" "$teamspeak_url"
fi
chmod +x "$teamspeak_installer"

find_teamspeak_dir() {
  for d in "$APPDIR/TeamSpeak3-Client"*; do
    if [[ -d "$d" ]]; then
      teamspeak_dir="$d"
      info "Teamspeak directory: $teamspeak_dir"
    fi
  done
}

find_teamspeak_dir

pushd "$APPDIR"
if [[ ! "$teamspeak_dir" ]]; then
  info "Running teamspeak installer"
  "$teamspeak_installer"
  find_teamspeak_dir
fi

teamspeak_runscript="$teamspeak_dir/ts3client_runscript.sh"
if [[ ! -f "$teamspeak_runscript" ]]; then
  fatal "didn't find ts3client_runscript.sh under $APPDIR as expected"
fi

if [[ ! -e "$teamspeak" ]]; then
  info "Creating teamspeak symlink"
  ln -s "$teamspeak_runscript" "$teamspeak"
fi
popd


### Install Synology Drive ###

notice "Installing Synology Drive"
synology_drive_url='https://global.download.synology.com/download/Tools/SynologyDriveClient/2.0.2-11078/Ubuntu/Installer/x86_64/synology-drive-client-11078.x86_64.deb'
synology_drive_package="$(basename "$synology_drive_url")"
synology_drive="$TMP/$synology_drive_package"
wget -O "$synology_drive" "$synology_drive_url"
dpkg -i "$synology_drive"

### Install Bitwig ###

notice "Installing Bitwig"
bitwig_url='https://downloads.bitwig.com/stable/3.2.7/bitwig-studio-3.2.7.deb'
bitwig_package="$(basename "$bitwig_url")"
bitwig="$TMP/$bitwig_package"
wget -O "$bitwig" "$bitwig_url"
dpkg -i "$bitwig"

# TODO: trilium
# TODO: my pomodoro timer
