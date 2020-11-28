#!/usr/bin/env bash
set -euo pipefail

readonly PROGNAME="$(basename "$0")"
readonly PROGDIR="$(dirname "$(readlink -f "$0")")"

# shellcheck source=messages.sh
source "$PROGDIR/messages.sh"

# shellcheck source=install-deb.sh
source "$PROGDIR/install-deb.sh"

as_me() {
  sudo -u "$USER" "$@"
}

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
  tree
  ubuntu-touch-sounds  # needed for super-simple-pomodoro
  okular
  calibre
  certbot
  python3-certbot-dns-digitalocean

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

  # docker
  docker-ce
  docker-ce-cli
  containerd.io
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

hledger_shell_path="Code/projects/hledger-shell"
pomodoro_path="Code/projects/pomodoro"

declare -A homedir_repos=(
  ["$hledger_shell_path"]="ssh://git@gitlab.zane.cloud:30001/joe/hledger-shell.git"
  ["Documents/ledger"]="ssh://git@gitlab.zane.cloud:30001/joe/ledger.git"
  ["Code/projects/my-hledger"]="git@github.com-pushittoprod:PushItToProd/my-hledger.git"
  ["$pomodoro_path"]="https://github.com/PushItToProd/super-simple-pomodoro.git"
)

[[ "$EUID" -eq 0 ]] || fatal "You must run this script as root."

USER=joe
USER_HOME=/home/$USER
APPDIR="$USER_HOME/$appdir_name"

notice "Setting up homedir"

mkdir -p "$APPDIR"

### Make sure git submodule dependencies are provided in homedir ###
cd "$USER_HOME"
if [[ ! -d .ssh ]]; then
  fatal "ssh keys need to be set up first"
fi

info "Updating Git submodules in homedir"
as_me bash -c 'cd ~; git submodule init; git submodule update'

info "Creating home directories: ${homedir_dirs[*]}"
as_me mkdir -p "${homedir_dirs[@]}"

info "Cloning repos"
for path in "${!homedir_repos[@]}"; do
  repo="${homedir_repos["$path"]}"
  info "Cloning $repo to $path"
  if [[ ! -d "$path" ]]; then
    as_me git clone "$repo" "$path"
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


### Spotify ###

notice "Installing Spotify"
as_me flatpak install flathub com.spotify.Client

### Docker Repo ###

notice "Installing Docker Repo"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"


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
  as_me code --install-extension "$ext"
done


### Install Hledger ###

notice "Installing hledger"
if [[ -f "$USER_HOME/.local/bin/hledger" ]]; then
  info "hledger is already installed"
else
  # hledger-install.sh is included in the repo for ease of distribution
  as_me bash /home/$USER/bin/hledger-install.sh
fi

info "Installing hledger-shell"
if [[ -f "$USER_HOME/.local/bin/hledger-shell" ]]; then
  info "hledger-shell is already installed"
else
  as_me pip3 install "$USER_HOME/$hledger_shell_path"
fi

### Install Discord ###

notice "Installing Discord"

discord_url="https://discordapp.com/api/download?platform=linux&format=deb"
discord_filename=discord.deb
install_deb --url "$discord_url" --file "$discord_filename" --name discord

### Install Rofimoji ###

notice "Installing Rofimoji for i3"

if as_me pip3 show rofimoji >/dev/null; then
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
  as_me pip3 install --user --no-warn-script-location "$rofimoji"
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
as_me pip3 install powerline-shell

### Use Zsh ###
notice "Switching to zsh"
chsh -s /usr/bin/zsh

### Install i3ipc ###
notice "Installing i3ipc for i3 Python scripts"
as_me pip3 install i3ipc

### Install Geckodriver for Selenium ###
notice "Installing geckodriver"
geckodriver_url='https://github.com/mozilla/geckodriver/releases/download/v0.27.0/geckodriver-v0.27.0-linux64.tar.gz'
geckodriver_tar="$(basename "$geckodriver_url")"
geckodriver_path="$APPDIR/geckodriver"
if [[ ! -f "$geckodriver_path" ]]; then
  wget "$geckodriver_url"
  tar -xvf "$geckodriver_tar"
  mv -f geckodriver "$APPDIR/"
fi

### Install Anki ###
notice "Installing anki"
anki_url='https://github.com/ankitects/anki/releases/download/2.1.30/anki-2.1.30-linux-amd64.tar.bz2'
anki_tar="$(basename "$anki_url")"
anki_dir="${anki_tar%.tar.bz2}"
if which anki &>/dev/null; then
  info "Anki is already installed"
else
  wget "$anki_url"
  tar xjf "$anki_tar"

  pushd "$anki_dir" >/dev/null
  sudo make install
  popd >/dev/null
fi

### Docker Compose ###
notice "Installing docker-compose"
if [[ ! -f /usr/local/bin/docker-compose ]]; then
  curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
fi

if [[ ! -x /usr/local/bin/docker-compose ]]; then
  chmod +x /usr/local/bin/docker-compose
fi

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

### Install Go ###
notice "Installing Go"
go_url='https://golang.org/dl/go1.15.5.linux-amd64.tar.gz'
go_tar="$(basename "$go_url")"
if [[ -d /usr/local/go ]]; then
  info 'Go is already installed'
else
  info 'Installing Go'
  wget "$go_url"
  tar -C /usr/local -xzf "$go_tar"
fi