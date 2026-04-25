# Ensure homebrew binaries take precedence over system binaries by adding the
# homebrew bin directory to the front of the PATH
if [[ -d /home/linuxbrew/.linuxbrew/bin ]]; then
  path=(/home/linuxbrew/.linuxbrew/bin $path)
fi

if [[ -d /opt/homebrew/bin ]]; then
  path=(/opt/homebrew/bin $path)
fi

if [[ -d /opt/homebrew/sbin ]]; then
  path=(/opt/homebrew/sbin $path)
fi
