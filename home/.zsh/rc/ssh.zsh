# two kinds of agents:
#   forwarded agents where $SSH_AUTH_SOCK is in /tmp
#   local agent listening on ~/.ssh/agent
function fixagent() {
  [[ -x =timeout ]] && to="timeout 2"
  $to ssh-add -l >/dev/null 2>&1 && return

  # over ssh, prefer a forwarded agent with keys if we can find a working one
  if [[ -n "$SSH_CLIENT" ]]; then
    for f in $(find /tmp/ssh-* -maxdepth 1 -user $USER -type s -name 'agent*' 2>/dev/null); do
      export SSH_AUTH_SOCK=$f
      $to ssh-add -l >/dev/null 2>&1 && return
    done
  fi

  # fall back to our local agent
  local local_agent="$HOME/.ssh/agent" lock="$HOME/.ssh/agent-lock"
  if [[ -e "$local_agent" ]]; then
    export SSH_AUTH_SOCK="$local_agent"
    $to ssh-add -l >/dev/null 2>&1
    rc=$?
    if [[ $rc == 0 ]]; then
      # running agent with keys!
      return
    elif [[ $rc == 1 ]]; then
      # running agent, no keys, good enough.
      return
    else
      # stale agent socket, remove it so we can start a new one
      rm -f "$local_agent"
    fi
  fi

  # if we have local keys, start an agent
  local keys keypath
  for key in id_ed25519 id_rsa; do
    keypath="$HOME/.ssh/$key"
    if [[ -e "$keypath" ]]; then
      keys="$keys $keypath"
    fi
  done

  # flock to avoid race conditions (multiple shells firing up at once with no agent)
  if [[ -n "$keys" ]]; then
    echo "=> starting local ssh-agent"
    flock -xno "$lock" -c "ssh-agent -a '$local_agent'" >/dev/null
    export SSH_AUTH_SOCK="$local_agent"
    flock -xn "$lock" -c "ssh-add $keys"
  fi
}

fixagent
