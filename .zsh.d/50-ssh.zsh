# ssh agent helper

# requires ~/.config/systemd/user/ssh-agent.service

__ssh_auth_sock="${XDG_RUNTIME_DIR}/ssh-agent.socket"

if [[ -S "$__ssh_auth_sock" ]]; then
  export SSH_AUTH_SOCK="$__ssh_auth_sock"
else
  {
    echo "ssh-agent socket not found: $__ssh_auth_sock"
    echo "is the ssh-agent.service running? ensure ~/.config/systemd/user/ssh-agent.service exists and try"
    echo "  systemctl --user enable --now ssh-agent"
    echo "and"
    echo "  systemctl --user status ssh-agent"
  } >&2
  # if you see ^^^ this error, ensure ~/.config/systemd/user/ssh-agent.service
  # exists and run `systemctl --user enable --now ssh-agent'
fi
