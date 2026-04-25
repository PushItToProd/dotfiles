# Ensure homebrew binaries take precedence over system binaries by adding the
# homebrew bin directory to the front of the PATH

if [[ "$__HOMEBREW_BASE_DIR" ]]; then
  :
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  __HOMEBREW_BASEDIR=/home/linuxbrew/.linuxbrew
elif [[ -d /opt/homebrew ]]; then
  __HOMEBREW_BASEDIR=/opt/homebrew
fi

## macOS homebrew paths
if [[ "$__HOMEBREW_BASEDIR" ]]; then
  path=("$__HOMEBREW_BASEDIR"/bin $path)
  __HOMEBREW_BIN="$__HOMEBREW_BASEDIR"/bin
  path=("$__HOMEBREW_BASEDIR"/sbin $path)
  __HOMEBREW_SBIN="$__HOMEBREW_BASEDIR"/sbin
  __HOMEBREW_OPT="$__HOMEBREW_BASEDIR"/opt
fi
