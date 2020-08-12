#!/usr/bin/env bash

notice() {
  local message="= $1 ="
  local messagelen="${#message}"
  echo ""
  printf '=%.0s' $(seq 1 "$messagelen")
  echo ""
  echo "$message"
  printf '=%.0s' $(seq 1 "$messagelen")
  echo ""
  echo ""
}

info() {
  echo "$(tput bold)$(tput setaf 14)** $*$(tput sgr0)" >&2
}

fatal() {
  echo "$(tput bold)$(tput setaf 1)ERROR: $*$(tput sgr0)" >&2
  exit 1
}