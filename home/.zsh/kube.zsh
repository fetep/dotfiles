# k: kubectl shortcut. no arguments toggles prompt info
function k() {
  # if run with no arguments, toggle prompt on/off
  if [[ $# -eq 0 ]]; then
    [[ -n "$_kube_prompt" ]] && unset _kube_prompt || _kube_prompt=1
    return 0
  fi

  _kube_prompt=1
  \kubectl "$@"
}

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
  _arguments "-l"
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

# kn: set kube namespace for current context
## kn autocomplete
function _kn() {
  _arguments "-l"
  _alternative "ns:namespace:($(_kn_list))"
}

function _kn_list() {
  kubectl -o 'name' get namespaces | cut -d/ -f2-
  return $pipestatus[1]
}

function _kn_usage() {
  echo "Usage: kn -l"
  echo "       kn namespace"
  echo ""
  echo "-l         List all available namespaces in current context"
  echo "namespace  New namespace to switch to"
}

function kn() {
  while getopts "hl" opt; do
    case "$opt" in
      h)
        _kn_usage
        return 0
        ;;
      l)
        _kn_list
        return $?
        ;;
      *)
        echo "kn: $opt: unknown option" >&2
        _kn_usage >&2
        return 1
    esac
  done
  shift $((OPTIND-1))

  if [[ $# != 1 ]]; then
    echo "kn: must pass exactly one argument (namespace)" >&2
    _kn_usage
    return 1
  fi

  _kube_prompt=1
  kubectl config set-context --current --namespace="$1" >/dev/null
  return $?
}

compdef _kn kn

# prompt hook to set _kube_context, used by prompt.zsh
add-zsh-hook precmd update-kube-vars

function update-kube-vars() {
  [[ -z "$_kube_prompt" ]] && return
  _kube_context=$(kubectl config view --minify -o jsonpath='{.current-context}/{...namespace}')
}

# load completion for k8s tools
for tool in flux helm kubectl kustomize; do
  if (( $+commands[$tool] )); then
    source <("$tool" completion zsh)
  fi
done

# k alias
if (( $+commands[kubectl] )); then
  compdef k=kubectl
fi
