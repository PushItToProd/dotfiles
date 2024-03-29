# ssh agent helper
# The file ~/.ssh/ssh_agent.zsh needs to exist and define a function
# add_ssh_keys which ssh-adds all the desired keys.

if [[ -f ~/.ssh/ssh_agent.zsh ]]; then
  . ~/.ssh/ssh_agent.zsh
  if ! typeset -f add_ssh_keys >/dev/null; then
    echo "warning: 50-ssh.zsh: ~/.ssh/ssh_agent.zsh does not " \
         "declare the function add_ssh_keys"
  fi
else
  echo "warning: 50-ssh.zsh: ~/.ssh/ssh_agent.zsh does not exist"
fi

ssh_agent_start() {
  eval "$(ssh-agent | tee ~/.ssh/agent.env)"
  add_ssh_keys
}

ssh_agent_restart() {
  kill $SSH_AGENT_PID
  ssh_agent_start
}

# start the agent only if one isn't already running
if [ -f ~/.ssh/agent.env ]; then
  . ~/.ssh/agent.env >/dev/null
  if ! kill -0 $SSH_AGENT_PID >/dev/null 2>&1; then
    echo "Stale agent file found. Spawning new agent."
    ssh_agent_start
  fi
else
  echo "Starting SSH agent"
  ssh_agent_start
fi
