### Docker Repo ###

notice "Installing Docker Repo"
if ! apt_repo_exists https://download.docker.com/linux/ubuntu; then

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
fi