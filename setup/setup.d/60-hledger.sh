### Install Hledger ###

notice "Installing hledger"
if [[ -f "$USER_HOME/.local/bin/hledger" ]]; then
  info "hledger is already installed"
else
  # hledger-install.sh is included in the repo for ease of distribution
  as_me bash /home/$USER/bin/hledger-install.sh
fi

info "Installing hledger-shell"
if [[ -f "$USER_HOME/.local/bin/hledger-shell" ]]; then
  info "hledger-shell is already installed"
else
  as_me pip3 install "$USER_HOME/$hledger_shell_path"
fi