# Run man and search for the given string.
mans() {
  local page="$1"
  shift
  local search="$*"
  # local search="${(j:.)@}"

  man -P "less -p \"^[ ]*$search\"" "$page"
}