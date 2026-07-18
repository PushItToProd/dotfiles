# enable tab completion of filenames using `.`, `_`, and `-` as word boundaries.
# e.g. typing
#     ls 9-c-z<TAB>
# completes to
#     ls 91-completions-zstyle.zsh
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
