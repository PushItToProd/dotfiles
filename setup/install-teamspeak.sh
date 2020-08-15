#!/usr/bin/env bash
set -euo pipefail

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "$0 can't be run directly. Run setup.sh instead" >&2
  exit 1
fi

notice "Installing Teamspeak"
teamspeak_url='https://files.teamspeak-services.com/releases/client/3.5.3/TeamSpeak3-Client-linux_amd64-3.5.3.run'
teamspeak_installer="$APPDIR/$(basename "$teamspeak_url")"
teamspeak="$APPDIR/teamspeak"
teamspeak_dir=

if [ ! -f "$teamspeak_installer" ]; then
  info "Downloading teamspeak"
  wget -O "$teamspeak_installer" "$teamspeak_url"
fi
chmod +x "$teamspeak_installer"

find_teamspeak_dir() {
  for d in "$APPDIR/TeamSpeak3-Client"*; do
    if [[ -d "$d" ]]; then
      teamspeak_dir="$d"
      info "Teamspeak directory: $teamspeak_dir"
    fi
  done
}

find_teamspeak_dir

pushd "$APPDIR"
if [[ ! "$teamspeak_dir" ]]; then
  info "Running teamspeak installer"
  "$teamspeak_installer"
  find_teamspeak_dir
fi

teamspeak_runscript="$teamspeak_dir/ts3client_runscript.sh"
if [[ ! -f "$teamspeak_runscript" ]]; then
  fatal "didn't find ts3client_runscript.sh under $APPDIR as expected"
fi

if [[ ! -e "$teamspeak" ]]; then
  info "Creating teamspeak symlink"
  ln -s "$teamspeak_runscript" "$teamspeak"
fi
popd
