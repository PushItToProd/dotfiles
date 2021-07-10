randpass() {
  openssl rand -base64 "${1:-32}" | tr -d '\n'
}
