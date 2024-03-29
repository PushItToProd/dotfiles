i3-binds() {
  grep --color=never -e '^[^#]*set' -e '^[^#]*bind' -e '^[^#]*mode' .config/regolith/i3/config
}

alias gdiff='git diff --no-index --color-words'
alias g=git
alias gs='git s'
alias gd='git d'
alias gds='git ds'
alias gc='git c'
alias gca='git ca'
alias gap='git ap'

alias ap='ansible-playbook'

randpass() {
  openssl rand -base64 "${1:-32}" | tr -d '\n'
}

alias -s code-workspace='code'