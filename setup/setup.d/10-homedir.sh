notice "Setting up homedir"

mkdir -p "$APPDIR"

### Make sure git submodule dependencies are provided in homedir ###
cd "$USER_HOME"
if [[ ! -d .ssh ]]; then
  fatal "ssh keys need to be set up first"
fi

info "Updating Git submodules in homedir"
as_me bash -c 'cd ~; git submodule init; git submodule update'

info "Creating home directories: ${homedir_dirs[*]}"
as_me mkdir -p "${homedir_dirs[@]}"

info "Cloning repos"
for path in "${!homedir_repos[@]}"; do
  repo="${homedir_repos["$path"]}"
  info "Cloning $repo to $path"
  if [[ ! -d "$path" ]]; then
    as_me git clone "$repo" "$path"
  fi
done