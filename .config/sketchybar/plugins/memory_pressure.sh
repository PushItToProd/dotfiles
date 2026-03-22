#!/usr/bin/env bash

get_pressure_level() {
  sysctl -n kern.memorystatus_vm_pressure_level
}

get_pressure_suffix() {
  case "$1" in
    1) printf "" ;;
    2) printf " (WARN)" ;;
    4) printf " (CRIT)" ;;
    *) printf " (UNKNOWN LVL: %s)" "$1" ;;
  esac
}

get_pressure_color() {
  case "$1" in
    1) printf '0xffffffff' ;;
    2) printf '0xfffcf400' ;;
    4) printf '0xfffc0000' ;;
    *) printf '0xfffc8200' ;;
  esac
}

get_free_memory_pct() {
  memory_pressure | awk '/System-wide memory free percentage/ { print $NF }'
}


main() {
  pressure="$(get_pressure_level)"
  label="$(get_free_memory_pct)$(get_pressure_suffix "$pressure")"
  label_color="$(get_pressure_color "$pressure")"

  if [[ "$*" == *--print* ]]; then
    printf '%s\n' "$label"
    return
  fi

  if [[ ! "$NAME" ]]; then
    echo "error: NAME is blank -- not calling 'sketchybar --set'" >&2
    printf 'label would be: "%s"\n' "$label"
    exit 1
  fi

  sketchybar --set "$NAME" label="$label" label.color="$label_color"
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi