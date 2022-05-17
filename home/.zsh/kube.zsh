# kube context/prompt helper
# if an argument is passed, assume that is a new namespace and enable prompt
# if no argument passed, toggles prompt on/off
function k() {
  while getopts "l" opt; do
    case "$opt" in
      l)
        kubectl config get-contexts
        return
        ;;
    esac
  done
  shift $((OPTIND-1))

  if [[ $# > 1 ]]; then
    echo "k: takes at most one argument (cluster/namespace)" >&2
    return 1
  elif [[ $# == 0 ]]; then
    # if run with no arguments, toggle prompt on/off
    if [[ -n "$_kube_prompt" ]]; then
      unset _kube_prompt
    else
      _kube_prompt=1
    fi
    return
  fi

  # one argument, can be the name of a context or a namespace.
  #   context/namespace
  #   context/
  #   namespace
  local target=$1
  if [[ "$target" != "${target##*/}" ]]; then
    # there is a "/" in $target, split into context and namespace
    local c="${target%%/*}" ns="${target##*/}"
    kubectl config use-context "$c" >/dev/null
    [[ -n $ns ]] && kubectl config set-context --current --namespace="$ns" >/dev/null
  else
    # no "/", assume a namespace
    kubectl config set-context --current --namespace="$1" >/dev/null
  fi

  _kube_prompt=1
  return
}

add-zsh-hook precmd update-kube-vars

function update-kube-vars() {
  [[ -z "$_kube_prompt" ]] && return
  _kube_context=$(kubectl config view --minify -o jsonpath='{.current-context}/{...namespace}')
}

if [[ -x =kubectl ]]; then
  source <(kubectl completion zsh)
fi
