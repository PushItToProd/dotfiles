### Install Go ###
notice "Installing Go"

GO_VERSION=1.17.2

go_url="https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz"
go_tar="$(basename "$go_url")"

install_go() {
  local installed_version=''
  local target_version="$GO_VERSION"

  if [[ -d /usr/local/go ]]; then
    installed_version="$(</usr/local/go/VERSION)" || true
    if [[ "$installed_version" != go* ]]; then
      fatal "unexpected go version format"
    fi
    # remove 'go' prefix
    installed_version="${installed_version#go}"

    installed_version="$(padversion "$installed_version")"
    target_version="$(padversion "$target_version")"

    if [[ "$installed_version" > "$target_version" ]]; then
      info 'Go is already installed and up to date'
      return
    else
      info "Go is installed but not the target version -- installed version: $GO_VERSION"
    fi
  fi
  info "Installing Go $GO_VERSION"
  wget "$go_url"
  tar -C /usr/local -xzf "$go_tar"
}
install_go

# update PATH for later scripts
export PATH="$PATH:/usr/local/go/bin"