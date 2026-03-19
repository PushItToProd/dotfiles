i3-binds() {
  grep --color=never -e '^[^#]*set' -e '^[^#]*bind' -e '^[^#]*mode' .config/regolith/i3/config
}

alias ap='ansible-playbook'

randpass() {
  openssl rand -base64 "${1:-32}" | tr -d '\n'
}

alias -s code-workspace='code'