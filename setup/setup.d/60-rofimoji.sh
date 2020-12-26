### Install Rofimoji ###

notice "Installing Rofimoji for i3"

if as_me pip3 show rofimoji >/dev/null; then
  info "rofimoji is already installed"
else
  # Package URL, filename, and download location
  rofimoji_url='https://github.com/fdw/rofimoji/releases/download/4.2.0/rofimoji-4.2.0-py3-none-any.whl'
  rofimoji_package="$(basename "$rofimoji_url")"
  rofimoji="$TMP/$rofimoji_package"

  # Download the package
  wget -O "$rofimoji" https://github.com/fdw/rofimoji/releases/download/4.2.0/rofimoji-4.2.0-py3-none-any.whl

  # Install rofimoji. --no-warn-script-location is here because ~/.local/bin isn't
  # on the path for the root user.
  as_me pip3 install --user --no-warn-script-location "$rofimoji"
fi