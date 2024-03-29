### Install Hledger ###
# https://hledger.org/download.html

notice "Installing hledger"
if [[ -f "$USER_HOME/.local/bin/hledger" ]]; then
  info "hledger is already installed"
else
  # hledger-install.sh is included in the repo for ease of distribution
  as_me bash "$USER_HOME/bin/hledger-install.sh"
fi

info "Installing hledger-shell"
if [[ -f "$USER_HOME/.local/bin/hledger-shell" ]]; then
  info "hledger-shell is already installed"
else
  as_me pip3 install "$USER_HOME/$hledger_shell_path"
fi