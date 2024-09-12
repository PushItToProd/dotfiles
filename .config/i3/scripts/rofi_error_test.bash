#!/usr/bin/env bash
# readonly PROGPATH="${BASH_SOURCE[0]}"
readonly PROGPATH="$(readlink -f "$0")"

cmdname=my_super_special_command_12345

log() {
  echo "$@" >&2
}

rofi_error() {
  echo -e "\0prompt\x1fError!\n"
  echo -e "\0no-custom\x1ftrue\n"
  echo -e "\0data\x1fFAIL\n"
  echo -e "Error: $*\0urgent\x1ftrue"
}

rofi_init() {
  if ! command -v "$cmdname"; then
    rofi_error "Couldn't find $cmdname"
    exit 1
  fi

  echo -e "\0prompt\x1fSelect your fighter"
}

main() {
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
