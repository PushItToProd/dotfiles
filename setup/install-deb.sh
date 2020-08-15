#!/usr/bin/env bash
# Grab a .deb file from the internet and install it if it isn't already
# installed.
set -euo pipefail

# shellcheck source=messages.sh
source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/messages.sh"

deb_is_installed() {
  dpkg-query -l "$1" &>/dev/null
}

install_deb::usage() {
  cat <<EOF
usage: install-deb --url DEB_URL --name DEB_NAME [options]

Options:
  --url     URL to the .deb package.
  --name    Installed package name.
  --force   Force install even if the package is already present.
  --tmp     Set temp path.
  --file    .deb filename to use (Defaults to last segment of URL. Required if
            the URL doesn't end with .deb.)
EOF
}

install_deb::parse_args() {
  while (( "$#" )); do
    case "$1" in
      --url)
        shift
        deb_url="$1"
        shift
        ;;
      --name)
        shift
        deb_name="$1"
        shift
        ;;
      --force)
        shift
        deb_force_install=1
        shift
        ;;
      --tmp)
        shift
        deb_tmp="$1"
        shift
        ;;
      --file)
        shift
        deb_filename="$1"
        shift
        ;;
      *) fatal "invalid argument to install-deb: $1" ;;
    esac
  done

  [[ "$deb_url" ]] || {
    install_deb::usage
    fatal "--url is required"
  }
  [[ "$deb_name" ]] || {
    install_deb::usage
    fatal "--name is required"
  }
}

install_deb() {
  local deb_url
  local deb_name
  local deb_force_install
  local deb_tmp
  local deb_filename
  local deb_file

  install_deb::parse_args "$@"

  # check if the package is installed
  if [[ "${deb_force_install:-}" == "" ]] && deb_is_installed "$deb_name"; then
    info "$deb_name is already installed - won't install without --force"
    return
  fi

  # init temp path
  if [[ "${deb_tmp:-}" == "" ]]; then
    deb_tmp=/tmp/machine_setup
  fi

  # get the package name
  if [[ "${deb_filename:-}" == "" ]]; then
    deb_filename="$(basename "$deb_url")"
    if [[ ! "$deb_filename" == *.deb ]]; then
      fatal "The URL $deb_url doesn't include a valid deb filename. Specify " \
            "one with --file."
    fi
  fi

  deb_file="$deb_tmp/$deb_filename"

  info "Downloading $deb_url"
  wget -O "$deb_file" "$deb_url"

  info "Installing $deb_name from $deb_filename"
  if ! dpkg -i "$deb_file"; then
    fatal "Installation failed."
  fi
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  install_deb "$@"
fi