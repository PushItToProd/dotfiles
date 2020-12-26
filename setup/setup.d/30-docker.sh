### Docker Repo ###

notice "Installing Docker Repo"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt_packages+=(
  # docker
  docker-ce
  docker-ce-cli
  containerd.io
)