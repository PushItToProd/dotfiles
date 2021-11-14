notice "Setting up Vagrant"
# via https://www.vagrantup.com/downloads
if ! apt-key list 2>/dev/null | grep -qi hashicorp; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
fi
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt_packages+=(vagrant)