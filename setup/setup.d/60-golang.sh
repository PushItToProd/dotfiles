### Install Go ###
notice "Installing Go"
go_url='https://dl.google.com/go/go1.17.linux-amd64.tar.gz'
go_tar="$(basename "$go_url")"
if [[ -d /usr/local/go ]]; then
  info 'Go is already installed'
else
  info 'Installing Go'
  wget "$go_url"
  tar -C /usr/local -xzf "$go_tar"
fi