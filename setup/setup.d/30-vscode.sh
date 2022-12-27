### VS Code Repo ###

notice "Installing VS Code Repo"

# https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions
if [[ ! -f /etc/apt/trusted.gpg.d/packages.microsoft.gpg ]]; then
  curl https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    > "$TMP/packages.microsoft.gpg"
  install -o root -g root -m 644 "$TMP/packages.microsoft.gpg" /etc/apt/trusted.gpg.d/
fi

echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

apt_packages+=(code)