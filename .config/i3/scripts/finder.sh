#!/usr/bin/env bash
# Adapted from /usr/share/rofi/modi/finder.sh, originally adapted from
# https://github.com/davatorium/rofi-scripts/blob/master/rofi-finder/finder.sh

ITEM_LIMIT=$(xrescat rofi.search.limit 64)
SHOW_HELP=$(xrescat rofi.search.help "true")

print_help() {
    echo "Returns matches from all local files"
    echo "Type search term, hit enter"
    echo "Type more for further filtering"
    echo "or scroll down"
    echo "Hit <enter> on a line to launch"
    echo "To scroll horizontally: <alt> ."
}

main() {
  # no arguments - initial run
  if (( "$#" == 0 )); then
    if [[ "$SHOW_HELP" == "true" ]]; then
      print_help
    fi
    return
  fi

  # arguments passed - handle them
  local QUERY="$*"
  if [[ "$QUERY" == /* ]]; then
    # An item was selected, try to launch it
    if [[ "$@" == *\?\? ]]; then
      QUERY="${QUERY%\/* \?\?}"
    fi

    coproc { xdg-open "$@"  > /dev/null 2>&1; }
    exec 1>&-
    return
  fi

  # TODO
}

main_old() {
  if [ ! -z "$@" ]; then
    # A search parameter was passed from the dialog
    QUERY=$@
    if [[ "$@" == /* ]]; then
      # A search item was selected, try to launch it
      if [[ "$@" == *\?\? ]]; then
        coproc ( xdg-open "${QUERY%\/* \?\?}"  > /dev/null 2>&1 )
        exec 1>&-
        exit;
      else
        coproc ( xdg-open "$@"  > /dev/null 2>&1 )
        exec 1>&-
        exit;
      fi
    elif [[ "$@" == \!\!* ]]; then
      # Help was requested, print it.
      print_help
    elif [[ "$@" == \?* ]]; then
      # Filter existing results
      while read -r line; do
        echo "$line" \?\?
      done <<< $(locate --limit $ITEM_LIMIT "$QUERY" 2>&1 | grep -v 'Permission denied\|Input/output error')
    else
      if [[ $QUERY = "~/"* ]]; then
        # Manually expand ~ to $HOME, based on https://unix.stackexchange.com/a/399439
        QUERY="${HOME}/${QUERY#"~/"}"
      fi
      if [[ -f "$QUERY" ]]; then
        # User entered a complete file path, so just launch it
        coproc ( xdg-open "$QUERY"  > /dev/null 2>&1 )
        exec 1>&-
        exit;
      else
        # Search for query
        locate --limit $ITEM_LIMIT $QUERY 2>&1 | grep -v 'Permission denied\|Input/output error'
      fi
    fi
  elif [[ "$SHOW_HELP" == "true" ]]; then
    #Initial execution, print help
    print_help
  fi
}
if [[ "$BASH_SOURCE" == "$0" ]]; then
  main "$@"
fi
