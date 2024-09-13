#!/usr/bin/env bash
# Demo of displaying an error message with Rofi.

readonly PROGPATH="$(readlink -f "$0")"

cmdname=my_super_special_command_12345

log() {
  echo "$@" >&2
}

# _rofi_error_internal displays an error message inside of rofi
_rofi_error_internal() {
  echo -e "\0prompt\x1fError!\n"
  echo -e "\0no-custom\x1ftrue\n"
  echo -e "\0data\x1fFAIL\n"
  echo -e "Error: $*\0urgent\x1ftrue"
}

# _rofi_error_external displays an error using rofi -e, which can't be invoked
# from inside of rofi.
_rofi_error_external() {
  local msg
  printf -v msg '%s\n%s\n' \
    '<span foreground="red" size="xx-large">Error</span>' \
    "$*"

  rofi -markup -e "$msg"
}

rofi_error() {
  if [[ -v ROFI_RETV ]]; then
    _rofi_error_internal "$@"
  else
    _rofi_error_external "$@"
  fi
}

rofi_init() {
  echo -e "\0prompt\x1fSelect your fighter"
}

main() {
  if ! command -v "$cmdname"; then
    rofi_error "Couldn't find $cmdname"
    exit 1
  fi

  if [[ "$ROFI_DATA" == FAIL ]]; then
    log "Failed with an error. Giving up"
    exit 1
  fi
  if [[ ! -v ROFI_RETV ]]; then
    # launch rofi
    rofi -show code -modi "code:bash $PROGPATH"
    return
  fi

  case "$ROFI_RETV" in
    0)
      # initial call
      rofi_init
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
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
