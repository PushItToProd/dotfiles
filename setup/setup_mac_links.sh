#!/usr/bin/env bash

PROGPATH="${BASH_SOURCE[0]}"
PROGDIR="$(cd "$(dirname "$PROGPATH")" && pwd -P)"

: "${DOTFILES_DIR="$(cd "$PROGDIR/.." && pwd -P)"}"
: "${INSTALL_DIR="$HOME"}"

: "${DRY_RUN=1}"

fatal() {
  printf 'fatal error: %s\n' "$*"
  exit 1
}

linklog() {
  printf '"%s": ' "$path"

}

link() {
  local path="$1"
  local src="$DOTFILES_DIR/$path"
  local dest="${2-"$INSTALL_DIR/$path"}"

  printf 'link: "%s": src="%s" <- dest="%s"\n' "$path" "$src" "$dest"
  if [[ ! -e "$src" ]]; then
    # printf '"%s": source "%s" does not exist\n' "$path" "$src" >&2
    fatal "\"$path\": source \"$src\" does not exist ⚠️"
  fi

  if [[ -L "$dest" ]]; then
    local symlink_path
    symlink_path=$(greadlink -f "$dest")
    if [[ "$symlink_path" == "$src" ]]; then
      printf '  -> "%s": already correctly linked ✅\n' "$path"
      return
    fi
    printf '  -> error: "%s" is already a symlink to "%s" ⚠️\n' "$path" "$symlink_path" >&2
    return 2
  fi

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    printf '  -> error: "%s": destination "%s" exists and is not a symlink ⚠️\n' "$path" "$dest"
    return 1
  fi

  if [[ "$DRY_RUN" ]]; then
    printf '  -> ** dry run: ln -s %q %q\n' "$src" "$dest"
  else
    ln -s "$src" "$dest"
  fi
}

main() {
  command -v greadlink &>/dev/null || fatal "greadlink not found - please 'brew install coreutils'" >&2

  echo "DOTFILES_DIR: $DOTFILES_DIR"
  echo "INSTALL_DIR: $INSTALL_DIR"

  link ".config/aerospace"
  mkdir -p "$INSTALL_DIR/.config/sketchybar"
  link ".config/sketchybar/sketchybarrc"
  link ".config/sketchybar/plugins"
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi