#!/usr/bin/env bash

notice() {
  local message="= $1 ="
  local messagelen="${#message}"
  tput bold
  tput setaf 14
  echo ""
  printf '=%.0s' $(seq 1 "$messagelen")
  echo ""
  echo "$message"
  printf '=%.0s' $(seq 1 "$messagelen")
  echo ""
  echo ""
  tput sgr0
}

info() {
  echo "$(tput bold)$(tput setaf 14)** $*$(tput sgr0)" >&2
}

error() {
  echo "$(tput bold)$(tput setaf 1)ERROR: $*$(tput sgr0)" >&2
}

fatal() {
  error "$@"
  exit 1
}

if [[ "$BASH_SOURCE" == "$0" ]]; then
  notice "This is a notice!"
  echo
  info "This is some info!"
  echo
  error "This is an error!"
fi