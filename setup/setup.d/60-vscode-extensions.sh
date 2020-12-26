### VS Code Extensions ###

vscode_extensions=(
  dcasella.i3
  felipe-mendes.slack-theme
  jetmartin.bats
  mads-hartmann.bash-ide-vscode
  mark-hansen.hledger-vscode
  mshr-h.veriloghdl
  dkundel.vscode-new-file
  samuelcolvin.jinjahtml
  stkb.rewrap
  timonwong.shellcheck
  vscodevim.vim
)

notice "Installing VS Code Extensions"
for ext in "${vscode_extensions[@]}"; do
  as_me code --install-extension "$ext"
done