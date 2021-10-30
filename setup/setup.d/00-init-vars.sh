
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
: "${SETUP_FORCE_INSTALL:=}"

apt_repos=(
  multiverse
)
apt_packages=(
  apt-transport-https
  calibre
  certbot
  code
  emacs
  ffmpeg        # bitwig
  gdebi-core    # discord
  gnome-tweaks
  keepassxc
  libgmp-dev    # hledger
  libtinfo-dev  # hledger
  okular
  openssh-server
  pavucontrol
  python3-certbot-dns-digitalocean
  python3-pip
  python3-venv
  shellcheck
  steam
  tmux
  tree
  ubuntu-touch-sounds  # needed for super-simple-pomodoro
  vim
  vlc
  wget
  xclip
  zsh
)