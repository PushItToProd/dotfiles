alias d='docker'
alias dps='docker ps'
alias dc='docker compose'
alias dcps='docker compose ps'
alias compose='docker compose'

dcrestart() {
  docker compose restart "$1" && docker compose logs --follow --tail 5 "$1"
}
