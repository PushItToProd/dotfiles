#!/usr/bin/env bash

readonly BASENAME="$(basename "$0")"

readonly RED="$(tput setaf 1)"
readonly BOLD="$(tput bold)"
readonly END="$(tput sgr0)"

readonly WORK_INTERVAL=25
readonly BREAK_INTERVAL=5

is_integer() {
    [[ "$1" =~ ^[[:digit:]]+$ ]]
}

err() {
    echo "$RED$BOLD$*$END" >&2
}

fail() {
    err "$*"
    exit 1
}

alert() {
    zenity --info --title="$BASENAME" --text="$*" 2>/dev/null
}

timer() {
  local interval="$1"
  local msg="$2"
  if [[ "$msg" == "" ]]; then
    msg="%s minutes remaining"
  fi
  for ((i="$interval"; i > 0; i--)); do
    printf "$msg\n" "$i"
    sleep 60
  done
}

do_work() {
  local -r interval="$1"
  timer "$interval" "%s minutes of work remaining"
  alert "All done working!"
}

do_break() {
  local -r interval="$1"
  timer "$interval" "%s minutes of break time remaining"
  alert "Get back to work!"
}

main() {
  while (( "$#" )); do
    case "$1" in
      -w) do_work "$WORK_INTERVAL" ;;
      -b) do_break "$BREAK_INTERVAL" ;;
      -W) shift
          do_work "$1" ;;
      -B) shift
          do_break "$1" ;;
    esac
    shift
  done
}
main "$@"
