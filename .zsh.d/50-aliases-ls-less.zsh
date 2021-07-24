# TODO: validate if this actually works
dir_is_not_empty() {
  # check visible files
  {
    : "$1"/*
    return 0  # found visible files
  } always {
    TRY_BLOCK_ERROR=0
  }

  # check hidden files
  {
    : "$1"/.*
    return 0
  } always {
    TRY_BLOCK_ERROR=0
  }

  return 1
} 2>/dev/null

dir_is_empty() {
  ! dir_is_not_empty "$@"
}

# like ls and less smashed into one
function llss {
  if [[ $# == 1 ]]; then
    # if there's one argument and it's a file, open it with less
    if [[ -f "$1" ]]; then
      less "$1"
      return
    fi


    if dir_is_empty "$1"; then
      echo "empty directory: $1" >&2
    fi
  fi

  ls "$@"
}
