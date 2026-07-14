alias _tmux="command -p tmux"

: "${TMUX_LAST_SESSION_FILE:=$HOME/.cache/tmux-last-session.tsv}"

# _tmux_record_last_session records, per client IP (from $SSH_CONNECTION),
# the last tmux session attached from this device, for use by tmux-resume.
# No-ops outside SSH since that's not a target use case.
_tmux_record_last_session() {
  local session="$1"
  [[ -n "$session" && -n "$SSH_CONNECTION" ]] || return 0
  local ip="${SSH_CONNECTION%% *}"
  mkdir -p "${TMUX_LAST_SESSION_FILE:h}"
  local tmp="${TMUX_LAST_SESSION_FILE}.tmp.$$"
  {
    [[ -f "$TMUX_LAST_SESSION_FILE" ]] && awk -F'\t' -v ip="$ip" '$1 != ip' "$TMUX_LAST_SESSION_FILE"
    printf '%s\t%s\n' "$ip" "$session"
  } > "$tmp" && mv "$tmp" "$TMUX_LAST_SESSION_FILE"
}

# _tmux_most_recent_session guesses which session a bare `tmux attach` (no
# -t) will pick, so it can be recorded before attaching.
_tmux_most_recent_session() {
  _tmux list-sessions -F '#{session_activity} #{session_name}' 2>/dev/null \
    | sort -rn | head -1 | cut -d' ' -f2-
}

__tmux_try_attach() {
  # any args provided => invoke tmux normally
  if [[ "$#" -gt 0 ]]; then
    _tmux "$@"
    return
  fi
  # no args => try attaching to existing session, otherwise start normally
  _tmux_record_last_session "$(_tmux_most_recent_session)"
  _tmux attach || _tmux
}

function _my_tmux_attach {
  local arg="$1"
  case "$arg" in
    ''|-*)
      _tmux_record_last_session "$(_tmux_most_recent_session)"
      tmux a "$@"
      ;;
    # arg provided and doesn't start with a `-` => assume first arg is a session
    # identifier
    *)
      _tmux_record_last_session "$arg"
      tmux a -t "$@"
      ;;
  esac
}

function _my_tmux_new {
  local arg1="$1"
  # TODO: add a `--pwd` flag to name the session after the current project dir
  case "$arg1" in
    ''|-*) tmux new-session "$@" ;;
    # arg provided and doesn't start with a `-` => assume first arg is a session
    # identifier
    *) tmux new-session -s "$@" ;;
  esac
}

function _tmux_attach_select {
  local -a sessions
  sessions=("${(@f)$(_tmux list-sessions -F '#S' 2>/dev/null)}")

  if [[ -z "$sessions[1]" ]]; then
    echo "No active tmux sessions."
    _my_tmux_new
    return
  fi

  local choice
  choice="$( (print -l "${sessions[@]}"; echo "new") | fzf --prompt="tmux session> " --height=~40% --reverse)"

  if [[ -z "$choice" ]]; then
    return
  elif [[ "$choice" == "new" ]]; then
    _my_tmux_new
  else
    # _my_tmux_attach records the session before attaching
    _my_tmux_attach "$choice"
  fi
}

alias tmux=__tmux_try_attach

alias t='tmux'
alias ta='_my_tmux_attach'
alias tat='_my_tmux_attach'
alias tls='tmux ls'
alias tnew='_my_tmux_new'
alias tas='_tmux_attach_select'
alias trs='tmux-resume'

alias ta0='_my_tmux_attach 0'
alias ta1='_my_tmux_attach 1'
alias ta2='_my_tmux_attach 2'
alias ta3='_my_tmux_attach 3'
alias ta4='_my_tmux_attach 4'
alias ta5='_my_tmux_attach 5'
alias ta6='_my_tmux_attach 6'
alias ta7='_my_tmux_attach 7'
alias ta8='_my_tmux_attach 8'
alias ta9='_my_tmux_attach 9'
