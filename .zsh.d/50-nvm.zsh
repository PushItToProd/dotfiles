alias nodejs=node

_init_nvm() {
  echo "info: initializing nvm" >&2

  # unset placeholders
  unset -f nvm
  unset -f npm
  unset -f node
  unset -f npx
  unset -f tsc
  unset -f ts-node

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

# XXX the next two functions are unused because they make startup slow
_generate_nvm_placeholder_src() {
  cat <<EOF
    $1() {
      _init_nvm;
      $1 \$@
    }
EOF
}

_init_nvm_placeholders() {
  local binaries=(nvm ~/.nvm/versions/node/*/bin/*)
  local name
  for binary in $binaries; do
    name=$(basename $binary)
    if ! which $name &>/dev/null; then
      eval "$(_generate_nvm_placeholder_src $(basename $binary))"
    fi
  done
}
# XXX end unused functions

# check if nvm is already declared -- if it isn't, initialize it and our
# placeholders
if ! command -v nvm &>/dev/null; then
  unset NVM_DIR
  nvm() {
    _init_nvm
    # execute nvm directly since it's a shell function that will overwrite this one
    nvm "$@"
  }

  # NOTE: The functions below must all be `unset` in _init_nvm! Otherwise these
  # functions will override their real counterparts on the path.
  npm() {
    _init_nvm
    npm "$@"
  }

  node() {
    _init_nvm
    node "$@"
  }

  npx() {
    _init_nvm
    npx "$@"
  }

  tsc() {
    _init_nvm
    tsc "$@"
  }

  ts-node() {
    _init_nvm
    ts-node "$@"
  }

fi
