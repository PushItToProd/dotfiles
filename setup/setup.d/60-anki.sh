### Install Anki ###
notice "Installing anki"
anki_url='https://github.com/ankitects/anki/releases/download/2.1.48/anki-2.1.48-linux-amd64.tar.bz2'
anki_tar="$(basename "$anki_url")"
anki_dir="${anki_tar%.tar.bz2}"
if [[ "$SETUP_FORCE_INSTALL" != *"anki"* ]] && which anki &>/dev/null; then
  info "Anki is already installed"
else
  wget "$anki_url"
  tar xjf "$anki_tar"

  pushd "$anki_dir" >/dev/null
  sudo make install
  popd >/dev/null
fi