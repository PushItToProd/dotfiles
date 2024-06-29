#!/usr/bin/env bash
# A script for downloading and installing the latest Go version.

: "${go_os:=linux}"
: "${go_arch:=amd64}"
: "${go_tmp_dir:=/tmp}"
: "${go_install_dir:=/usr/local/go}"
: "${go_install_basedir:=${go_install_dir%/go}}"

fatal() {
  echo "fatal error:" "$@" >&2
  exit 1
}

_parse_go_dl_json() {
  jq \
    --arg go_os "$go_os" \
    --arg go_os_arch "$go_arch" \
    -r \
    '.[0].files[] | select (.os == $go_os and .arch == $go_os_arch).filename'
}

# get_latest_go_url sets go_url and go_filename
get_latest_go_url() {
  local json
  # per https://github.com/golang/go/issues/51135, we should use this URL to get
  # the URL of the package to download.
  json="$(curl --silent 'https://go.dev/dl/?mode=json')"
  go_filename="$(_parse_go_dl_json <<<"$json")"
  if [[ ! "$go_filename" ]]; then
    fatal "error: Failed to get an appropriate package from the API"
  fi

  printf -v go_url '%s' "https://go.dev/dl/$go_filename"
}

# download_go downloads the file at $go_url to the path $go_dl_file, which
# defaults to /tmp/$go_filename
download_go() {
  echo "** Go will be downloaded to $go_dl_file"
  if [[ "$DRY_RUN" ]]; then
    return
  fi
  curl -L --output "$go_dl_file" "$go_url"
}

purge_old_go() {
  if [[ ! -d "$go_install_dir" ]]; then
    echo "** Go is not installed - skipping cleanup" >&2
    return
  fi
  if [[ "$DRY_RUN" ]]; then
    echo "** Removing old Go install at $go_install_dir" >&2
    return
  fi
  go_backup_dir="$(mktemp -d '/tmp/old_go.XXXXXXXX')"
  echo "** Moving $go_install_dir into $go_backup_dir"
  if ! mv -t "$go_backup_dir" "$go_install_dir"; then
    fatal "failed to remove old go install at $go_install_dir"
  fi
}

install_go() {
  echo "** untarring $go_dl_file into $go_install_basedir"
  if [[ "$DRY_RUN" ]]; then
    return
  fi
  if ! tar -C "${go_install_basedir}" -xzf "$go_dl_file"; then
    fatal "failed to untar go into $go_install_basedir"
  fi
}

main() {
  if [[ "$*" == *-d* ]]; then
    echo "** Running as a dry run"
    DRY_RUN=1
  fi

  if [[ ! "$DRY_RUN" ]] && [[ ! -w "$go_install_basedir" ]]; then
    fatal "you don't have write permission on $go_install_basedir - try sudo"
  fi
  local go_filename go_url
  echo "** getting Go for OS $go_os and architecture $go_arch"
  get_latest_go_url  # updates go_url and go_filename
  echo "** got Go URL: $go_url"
  echo "** got Go filename: $go_filename"

  if [[ "$go_url" != *.tar.gz ]]; then
    fatal "expected a .tar.gz archive but got something else instead"
  fi

  : "${go_dl_file:="$go_tmp_dir/$go_filename"}"

  download_go
  purge_old_go
  install_go
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
