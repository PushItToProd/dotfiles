# ssh agent helper

ssh_agent_start() {
  eval "$(ssh-agent | tee ~/.ssh/agent.env)"
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
