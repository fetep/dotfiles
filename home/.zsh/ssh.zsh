# two kinds of agents:
#   forwarded agents where $SSH_AUTH_SOCK is in /tmp
#   local agent listening on ~/.ssh/agent
function fixagent() {
  [[ -x =timeout ]] && to="timeout 2"
  $to ssh-add -l >/dev/null 2>&1 && return

  # prefer a forwarded agent if we can find a working one
  for f in $(find /tmp/ssh-* -maxdepth 1 -user $USER -type s -name 'agent*' 2>/dev/null); do
    export SSH_AUTH_SOCK=$f
    $to ssh-add -l >/dev/null 2>&1 && return
  done

  # fall back to our local agent
  local local_agent="$HOME/.ssh/agent"
  if [[ -e "$local_agent" ]]; then
    export SSH_AUTH_SOCK="$local_agent"
    $to ssh-add -l >/dev/null 2>&1 && return
  fi

  # if we have local keys, start an agent
  local keys keypath
  for key in id_ed25519 id_rsa; do
    keypath="$HOME/.ssh/$key"
    if [[ -e "$keypath" ]]; then
      keys="$keys $keypath"
    fi
  done

  if [[ -n "$keys" ]]; then
    echo "=> starting local ssh-agent"
    ssh-agent -a "$local_agent" >/dev/null
    export SSH_AUTH_SOCK="$local_agent"
    ssh-add $keys
  fi
}

fixagent
