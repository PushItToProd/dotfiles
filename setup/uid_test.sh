#!/usr/bin/env bash

[[ "$EUID" -eq 0 ]] || echo "You must run this script as root."

echo "EUID: $EUID"
echo "UID: $UID"
echo "USER: $USER"
echo "SUDO_USER: $SUDO_USER"