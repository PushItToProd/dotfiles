i3-binds() {
  grep --color=never -e '^[^#]*set' -e '^[^#]*bind' -e '^[^#]*mode' .config/regolith/i3/config
}

randpass() {
  openssl rand -base64 "${1:-32}" | tr -d '\n'
}

# suffix alias: `blah.code-workspace` => `code blah.code-workspace`
alias -s code-workspace='code'
