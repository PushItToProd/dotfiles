i3_binds() {
  grep -e '^[^#]*bind' -e '^[^#]*mode' .config/i3/config
}