#!/usr/bin/env bash

PROGPATH="${BASH_SOURCE[0]}"
PROGDIR="$(cd "$(dirname "$PROGPATH")" && pwd -P)"

: "${DOTFILES_DIR="$(cd "$PROGDIR/.." && pwd -P)"}"
: "${INSTALL_DIR="$HOME"}"

# Run with `DRY_RUN=0` to overwrite
: "${DRY_RUN=1}"

fatal() {
  printf 'fatal error: %s\n' "$*"
  exit 1
}

linklog() {
  printf '"%s": ' "$path"

}

# -s: symlink
# -i: interactively prompt to overwrite (as long as the other precondition
#     checks are satisified - i.e. the existing file matches the src exactly)
# -F: allow overwriting directories
: "${LN_FLAGS:=-siF}"

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
    printf '  -> error: "%s" is already a symlink to "%s" - not changing to "%s" ⚠️\n' "$path" "$symlink_path" "$src" >&2
    return 2
  fi

  # XXX: pretty sure the `-L` check here is superfluous
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    if ! diff -rq "$src" "$dest" &>/dev/null; then
      printf '  -> error: "%s": destination "%s" exists, is not a symlink, and has different content than the source ⚠️\n' "$path" "$dest"
      return 1
    fi
    printf '  -> "%s": destination "%s" exists, is not a symlink, and is identical to the source - safe to overwrite\n' "$path" "$dest"
  fi

  if [[ "$DRY_RUN" ]]; then
    printf '  -> ** ⛔️ dry run: ln %s %q %q\n' "$LN_FLAGS" "$src" "$dest"
    return
  fi
  ln "$LN_FLAGS" "$src" "$dest"
}

ensure_dir() {
  local path="$1"
  local dir="$INSTALL_DIR/$path"

  mkdir -p "$dir" || fatal "couldn't create path '$path' ⚠️"
  printf 'ensure_dir: "%s" ✅\n' "$path"
}

main() {
  command -v greadlink &>/dev/null || fatal "greadlink not found - please 'brew install coreutils'" >&2

  echo "DOTFILES_DIR: $DOTFILES_DIR"
  echo "INSTALL_DIR: $INSTALL_DIR"

  echo
  echo ---
  echo

  ensure_dir .config
  link ".config/aerospace"
  ensure_dir "$INSTALL_DIR/.config/sketchybar"
  link ".config/sketchybar/sketchybarrc"
  link ".config/sketchybar/plugins"

  ensure_dir "$INSTALL_DIR/bin"
  link "bin/list_vscode_workspaces"

  link ".gitconfig"
  link ".gitignore_global"

  link ".vimrc"
  link ".vimconfig"

  link ".zprofile"

}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi