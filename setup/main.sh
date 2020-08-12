#!/usr/bin/env bash
set -euo pipefail

readonly PROGNAME="$(basename "$0")"
readonly DIR="$(dirname "$(readlink -f "$0")")"

source "$DIR/messages.sh"

declare -a pre_install_tasks=()
declare -a install_tasks=(
  install_apt_packages
)
declare -a post_install_tasks=()
declare -a apt_packages=()

install_apt_packages() {
  notice "Installing Packages"
  apt-get update
  apt-get install "${apt_packages[@]}"
}

main() {
  [[ "$EUID" -eq 0 ]] || fatal "You must run this script as root."
  [[ "$SUDO_USER" != "" ]] || fatal "expected SUDO_USER to be set but it's null"

  USER="$SUDO_USER"

  TMP=/tmp/machine_setup
  mkdir -p "$TMP"
  cd "$TMP"

  for module in "$DIR/modules/*.sh"; do
    source "$module"
  done

  for task in "${pre_install_tasks[@]}"; do
    "$task"
  done

  for task in "${install_tasks[@]}"; do
    "$task"
  done

  for task in "${post_install_tasks[@]}"; do
    "$task"
  done
}
if [[ "$BASH_SOURCE" == "$0" ]]; then
  main "$@"
fi