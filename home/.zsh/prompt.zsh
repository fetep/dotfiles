unset PS1 PROMPT
unset RPS1 RPROMPT

autoload -U colors
colors

prompt_git_status() {
  [[ -z $_git_ref ]] && return

  local dirty=0 gsp summary
  typeset -A summary

  gsp=$(command git status --porcelain)

  if [[ -n $gsp ]]; then
    for line in "${(@f)${gsp}}"; do
      local gitstat=$line[(w)1]
      summary[$gitstat]=$((summary[$gitstat] + 1))
      dirty=1
    done
  fi

  local color
  if [[ $dirty -eq 1 ]]; then
    color="yellow"
  elif [[ $ahead -ne 0 ]]; then
    color="green"
  else
    color="green"
  fi

  echo -n -e "{ git: %{$fg_bold[$color]%}${_git_ref}%{%f%b%} "


  for k in "${(@k)summary}"; do
    echo -n "[$k:$summary[$k]] "
  done

  echo -n "} "

  _pre_prompt=1
}

prompt_python_venv() {
  [[ -z $_python_venv ]] && return

  echo -n -e "{ venv: ${_python_venv##*/} } "
  _pre_prompt=1
}

prompt_rack_env() {
  [[ -z $_rack_dir ]] && return

  local color=0

  case $RACK_ENV in
    prod*)
      echo -n -e "{ RACK_ENV: %{$fg_bold[red]%}${RACK_ENV}%{%f%b%} } "
      ;;
    *)
      echo -n -e "{ RACK_ENV: ${RACK_ENV} } "
  esac

  _pre_prompt=1
}

prompt_rc() {
  if [[ $RETVAL -ne 0 ]]; then
    echo -n "%{$fg_bold[red]%}${RETVAL}%{%f%b%} "
  else
    echo -n "${RETVAL} "
  fi
}

prompt_context() {
  local u h=$HOST d="%~"
  [[ "$_me" = "false" ]] && u="${USERNAME}@"
  if [[ -n "$DEVSHELL" ]]; then
    h="${h%%-ds-*}-ds/${DEVSHELL}"
  fi

  # if we're in a git repo, change the path to be relative to the git root
  if [[ -n "$_git_root" ]]; then
    d="${_git_repo}${PWD##$_git_root}"
  fi

  echo -n "${u}${h}(%35<...<${d}) "
}

prompt_git_branch() {
  local color

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ref=$(git symbolic-ref HEAD 2>/dev/null || git show-ref --head -s --abbrev | head -n 1 2>/dev/null)
    dirty=$(command git status --porcelain 2>/dev/null)

    if [[ -n $dirty ]]; then
      color="yellow"
    else
      color="green"
    fi

    echo -n "%{$fg_bold[$color]%}${ref/refs\/heads\//}%{%f%b%} "
  fi
}

prompt_kube_context() {
  if [[ -z "$_kube_prompt" ]]; then
    return
  fi

  echo -n -e "{ kube: ${_kube_context} } "
  _pre_prompt=1
}

prompt_end() {
  echo -n "%# "
}

build_prompt() {
  RETVAL=$?
  _pre_prompt=""

  # first optional line
  prompt_git_status
  prompt_python_venv
  prompt_rack_env
  prompt_kube_context

  if [[ -n "$_pre_prompt" ]]; then
    echo ""
  fi

  # actual prompt
  prompt_rc
  prompt_context
  prompt_end
}

setopt prompt_subst

PROMPT='%{%f%b%k%}$(build_prompt)'
unset RPROMPT RPS1
