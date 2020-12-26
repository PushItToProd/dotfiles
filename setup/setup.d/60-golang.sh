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