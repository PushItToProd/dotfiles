
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

USER=joe
USER_HOME=/home/$USER
APPDIR="$USER_HOME/$appdir_name"

apt_repos=(
  multiverse
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

  # zsh
  zsh
)