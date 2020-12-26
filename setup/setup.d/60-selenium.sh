### Install Geckodriver for Selenium ###
notice "Installing geckodriver"
geckodriver_url='https://github.com/mozilla/geckodriver/releases/download/v0.27.0/geckodriver-v0.27.0-linux64.tar.gz'
geckodriver_tar="$(basename "$geckodriver_url")"
geckodriver_path="$APPDIR/geckodriver"
if [[ ! -f "$geckodriver_path" ]]; then
  wget "$geckodriver_url"
  tar -xvf "$geckodriver_tar"
  mv -f geckodriver "$APPDIR/"
fi