[[ -o interactive ]] || return

# two kinds of agents:
#   forwarded agents where $SSH_AUTH_SOCK is in /tmp
#   local agent listening on ~/.ssh/agent
function fixagent() {
  [[ -x =timeout ]] && to="timeout 2"
  $to ssh-add -l >/dev/null 2>&1 && return

  # always prefer a local agent if keys exist on this host
  # if we have local keys, start an agent
  local key keys=""
  for key in id_ed25519; do
    if [[ -e "$HOME/.ssh/$key" ]]; then
      keys="$keys $HOME/.ssh/$key"
    fi
  done
  if [[ -n "$keys" ]]; then
    local local_agent="$HOME/.ssh/agent" lock="$HOME/.ssh/agent-lock"
    export SSH_AUTH_SOCK="$local_agent"
    $to ssh-add -l >/dev/null 2>&1 && return

    rm -f "$local_agent"
    echo "zsh: starting local ssh-agent (with $keys)" >&2
    # flock to avoid race conditions (multiple shells firing up at once with no agent)
    flock -xno "$lock" -c "ssh-agent -a '$local_agent'" >/dev/null
    flock -xn "$lock" -c "ssh-add $keys"
  fi

  # look for a working forwarded agent
  for f in $(find /tmp/ssh-* -maxdepth 1 -user "$USER" -type s -name 'agent*' 2>/dev/null); do
    export SSH_AUTH_SOCK=$f
    $to ssh-add -l >/dev/null 2>&1 && return
  done

  # if we made it here, there's no local keys and no forwarded agent.
  unset SSH_AUTH_SOCK
}
