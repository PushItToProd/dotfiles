# Use fd for file listing: respects ignore files and includes dotfiles while 
# excluding .git. On Debian/Ubuntu the binary is `fdfind`; fall back to `fd` elsewhere.
if (( $+commands[fdfind] )); then
  _fd_cmd=fdfind
elif (( $+commands[fd] )); then
  _fd_cmd=fd
fi

__fzf_cmd_args='--no-ignore-vcs --hidden --strip-cwd-prefix --exclude .git --exclude node_modules --exclude .venv --exclude venv'
__fzf_cmd_args='--no-ignore-vcs --hidden --strip-cwd-prefix'

if [[ -n $_fd_cmd ]]; then
  export FZF_DEFAULT_COMMAND="$_fd_cmd --type f $__fzf_cmd_args"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  # Ctrl+T's alt-c dir jumper: same excludes, directories only.
  export FZF_ALT_C_COMMAND="$_fd_cmd --type d $__fzf_cmd_args"
fi
unset _fd_cmd
unset _fzf_cmd_args

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
