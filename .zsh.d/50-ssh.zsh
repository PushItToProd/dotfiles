# ssh agent helper

# requires ~/.config/systemd/user/ssh-agent.service

__ssh_auth_sock="${XDG_RUNTIME_DIR}/ssh-agent.socket"

if [[ "$SSH_AUTH_SOCK" ]]; then
  :  # do nothing - already set
elif [[ ! -S "$__ssh_auth_sock" ]]; then
  {
    echo "ssh-agent socket not found: $__ssh_auth_sock"
    echo "is the ssh-agent.service running? ensure ~/.config/systemd/user/ssh-agent.service exists and try"
    echo "  systemctl --user enable --now ssh-agent"
    echo "and"
    echo "  systemctl --user status ssh-agent"
  } >&2
  # if you see ^^^ this error, ensure ~/.config/systemd/user/ssh-agent.service
  # exists and run `systemctl --user enable --now ssh-agent'
else
  export SSH_AUTH_SOCK="$__ssh_auth_sock"
fi
