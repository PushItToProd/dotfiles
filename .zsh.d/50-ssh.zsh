if [[ -f ~/.ssh/ssh_agent.ssh ]]; then
  . ~/.ssh/ssh_agent.zsh
fi


# ~./ssh/ssh_agent.zsh is a script containing the following:
#start_ssh_agent() {
#  eval "$(ssh-agent | tee ~/.ssh/agent.env)"
#  ssh-add ~/.ssh/id_ed25519
#  ssh-add ~/.ssh/github.com-pushittoprod
#}
#
#if [ -f ~/.ssh/agent.env ]; then
#  . ~/.ssh/agent.env >/dev/null
#  if ! kill -0 $SSH_AGENT_PID >/dev/null 2>&1; then
#    echo "Stale agent file found. Spawning new agent."
#    start_ssh_agent
#  fi
#else
#  echo "Starting SSH agent"
#  start_ssh_agent
#fi
