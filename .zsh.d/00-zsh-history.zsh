HISTFILE=~/.zsh_history
HISTSIZE=90000
SAVEHIST=150000
setopt appendhistory      # append history instead of overwriting
setopt incappendhistory   # immediately append commands to the history file

# example from the zsh docs - write a per-directory history
# zshaddhistory() {
#   print -sr -- ${1%%$'\n'}
#   fc -p .zsh_local_history
# }

# localhist() {
#   tail .zsh_local_history
# }