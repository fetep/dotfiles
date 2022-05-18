# k: set kube namespace for current context
# also toggles kubectl context details in prompt
function _k_usage() {
  echo "Usage: k -l"
  echo "       k namespace"
  echo "       k"
  echo ""
  echo "-l         List all available namespaces in current context"
  echo "namespace  New namespace to switch to"
  echo ""
  echo "Calling k without arguments will toggle displaying current context/namespace in prompt"
}

# list namespaces
function _k_list() {
  kubectl -o 'name' get namespaces | cut -d/ -f2-
  return $pipestatus[1]
}

# autocomplete for 'k'
function _k() {
  _arguments "-l" "-h"
  _alternative "ns:namespace:($(_k_list))"
}

function k() {
  while getopts "hl" opt; do
    case "$opt" in
      h)
        _k_usage
        return 0
        ;;
      l)
        _k_list
        return $?
        ;;
      *)
        _k_usage >&2
        return 1
    esac
  done
  shift $((OPTIND-1))

  if [[ $# > 1 ]]; then
    echo "k: takes at most one argument (namespace)" >&2
    _k_usa
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

  _kube_prompt=1
  kubectl config set-context --current --namespace="$1" >/dev/null
  return $?
}

compdef _k k

# kc: set kube context
function _kc_usage() {
  echo "Usage: kc -l"
  echo "       kc context"
  echo ""
  echo "-l       List all available kubectl contexts"
  echo "context  New context to switch to"
}

# autocomplete for 'kc'
function _kc() {
  _arguments "-l" "-h"
  _alternative "c:context:($(kubectl config get-contexts -o name))"
}

function kc() {
  while getopts "hl" opt; do
    case "$opt" in
      h)
        _kc_usage
        return 0
        ;;
      l)
        kubectl config get-contexts
        return $?
        ;;
      *)
        _kc_usage >&2
        return 1
    esac
  done
  shift $((OPTIND-1))

  if [[ $# != 1 ]]; then
    echo "kc: must pass exactly one argument (context)" >&2
    _kc_usage >&2
    return 1
  fi

  _kube_prompt=1
  kubectl config use-context "$1" >/dev/null
  return $?
}

compdef _kc kc

# prompt hook to set _kube_context, used by prompt.zsh
add-zsh-hook precmd update-kube-vars

function update-kube-vars() {
  [[ -z "$_kube_prompt" ]] && return
  _kube_context=$(kubectl config view --minify -o jsonpath='{.current-context}/{...namespace}')
}

# load completion for k8s tools
for tool in flux helm kubectl kustomize; do
  if [[ -x =$tool ]]; then
    source <("$tool" completion zsh)
  fi
done
