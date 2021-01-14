#!/usr/bin/env bash
set -euo pipefail

readonly PROGNAME="$(basename "$0")"
readonly PROGDIR="$(dirname "$(readlink -f "$0")")"

# shellcheck source=messages.sh
source "$PROGDIR/messages.sh"

# shellcheck source=install-deb.sh
source "$PROGDIR/install-deb.sh"

as_me() {
  sudo -u "$USER" "$@"
}

[[ "$EUID" -eq 0 ]] || fatal "You must run this script as root."

if [[ ! -d "$PROGDIR/setup.d" ]]; then
  fatal "Can't find setup.d under program directory $PROGDIR"
fi

for mod in "$PROGDIR/setup.d/"*.sh; do
  info "Running setup step $mod"
  source "$mod"
done