### Install Anki ###

anki_version=2.1.49
notice "Installing anki $anki_version"
anki_url="https://github.com/ankitects/anki/releases/download/$anki_version/anki-$anki_version-linux.tar.bz2"
anki_tar="$(basename "$anki_url")"
anki_dir="${anki_tar%.tar.bz2}"

anki_installed_version=
if command -v anki &>/dev/null; then
  anki_installed_version="$(anki --version)"
  anki_installed_version="${anki_installed_version##Anki }"
fi

if [[ "$SETUP_FORCE_INSTALL" != *"anki"* ]] && [[ "$anki_installed_version" == "$anki_version" ]]; then
  info "Anki is already installed"
else
  wget "$anki_url"
  tar xjf "$anki_tar"

  pushd "$anki_dir" >/dev/null || fatal "Unable to switch to anki directory $anki_dir"
  sudo make install
  popd >/dev/null || fatal "Unable to return from anki directory"
fi