### Docker Compose ###
notice "Installing docker-compose"
if [[ ! -f /usr/local/bin/docker-compose ]]; then
  curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
fi

if [[ ! -x /usr/local/bin/docker-compose ]]; then
  chmod +x /usr/local/bin/docker-compose
fi