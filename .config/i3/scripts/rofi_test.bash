#!/usr/bin/env bash
# Testing out Rofi.

readonly PROGPATH="$(readlink -f "$0")"

log() {
  echo "$@" >&2
}

rofi_row() {
  local text="$1"
  shift
  printf '%s' "$text"
  if (( $# )); then
    printf '\0'
    printf '%s' "$1"
    shift
    printf '\x1f%s' "$@"
  fi
  printf '\n'
}

print_options() {
  # echo -e "Option 1\0icon\x1ffolder\x1fpermanent\x1ftrue"
  rofi_row 'Option 1' icon folder permanent true
  echo -e "Option 2"
  echo -e "Option 3"
  echo -e "Option 4"
  echo -e "Option 5"
  echo -e "Option 6"
  echo -e "Option 7"
  echo -e "Option 8"
  echo -e "Option 9"
  echo -e "Option 10"
  echo -e "Option 11"
  echo -e "Option 12"
  echo -e "Option 13"
  echo -e "Option 14"
  echo -e "Option 15"
  echo -e "Option 16"
  echo -e "Option 17"
  echo -e "Option 18"
  echo -e "Option 19"
  echo -e "Option 20"
}

main() {
  if [[ ! -v ROFI_RETV ]]; then
    # launch rofi
    rofi -show code -modi "code:bash $PROGPATH"
    return
  fi

  log "** ROFI vars: **"
  declare -p | grep ' ROFI_.*=' >&2
  log "****************"
  log

  case "$ROFI_RETV" in
    0)
      # initial call
      echo -en "\0prompt\x1fSelect your fighter\n"
      echo -en "\0message\x1fCustom message\n"
      echo -en "\0urgent\x1f2\n"
      echo -en "\0active\x1f3\n"

      print_options
      ;;
    1)
      # entry selected
      selection="$1"
      log "Entry selected: $selection"
      ;;
    2)
      # custom entry selected
      selection="$1"
      log "Custom entry selected: $selection"
      ;;
    *)
      log "Custom keybinding: $ROFI_RETV"
      ;;
  esac

  log "** script terminating **"
  log
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi