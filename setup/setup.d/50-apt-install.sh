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