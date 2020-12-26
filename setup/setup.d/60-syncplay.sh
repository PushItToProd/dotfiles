### Install Syncplay ###
notice "Installing Syncplay"
syncplay_url='https://github.com/Syncplay/syncplay/releases/download/v1.6.5/Syncplay-1.6.5-x86_64.AppImage'
syncplay="$APPDIR/Syncplay"
if [[ ! -f "$syncplay" ]]; then
  wget -O "$syncplay" "$syncplay_url"
fi
chmod +x "$syncplay"