# kube context/prompt helper
# if an argument is passed, assume that is a new namespace and enable prompt
# if no argument passed, toggles prompt on/off
function k() {
  if [[ $# > 1 ]]; then
    echo "k: takes at most one argument (namespace)" >&2
    return 1
  elif [[ $# == 1 ]]; then
    kubectl config set-context --current --namespace="$1" >/dev/null
    _kube_prompt=1
    return
  fi

  if [[ -n "$_kube_prompt" ]]; then
    unset _kube_prompt
  else
    _kube_prompt=1
  fi
}

add-zsh-hook precmd update-kube-vars

function update-kube-vars() {
  [[ -z "$_kube_prompt" ]] && return

  _kube_context=$(kubectl config view -o jsonpath='{.current-context}/{...namespace}')
}

if [[ -x =kubectl ]]; then
  source <(kubectl completion zsh)
fi
