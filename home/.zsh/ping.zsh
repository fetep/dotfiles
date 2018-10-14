function pingw() {
  local last_state="_"
  local state

  if [[ $# -ne 1 ]]; then
    echo "usage: pingw <host>" >&2
    return 1
  fi

  host=$1
  if [[ $host =~ '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' ]]; then
    : # ip addr, no need to resolve
  elif ! getent hosts $host >/dev/null 2>&1; then
    echo "pingw: $host: not found" >&2
    return 2
  fi

  while :; do
    if fping -q $host; then
      state="up"
    else
      state="down"
    fi
    if [[ $state != $last_state ]]; then
      echo "$(date) $host $state"
    fi
    last_state=$state
    sleep 1
  done
}
