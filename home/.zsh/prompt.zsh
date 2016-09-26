unset PS1 PROMPT
unset RPS1 RPROMPT

autoload -U colors
colors

prompt_git_status() {
  if [[ -z $_git_ref ]]; then
    return 0
  fi

  local dirty=0
  local summary
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

  return 1
}

prompt_rack_env() {
  if [[ -z $_rack_dir ]]; then
    return 0
  fi

  local color=0

  case $RACK_ENV in
    prod*)
      echo -n -e "{ RACK_ENV: %{$fg_bold[red]%}${RACK_ENV}%{%f%b%} } "
      ;;
    *)
      echo -n -e "{ RACK_ENV: ${RACK_ENV} } "
  esac

  return 1
}

prompt_rc() {
  if [[ $RETVAL -ne 0 ]]; then
    echo -n "%{$fg_bold[red]%}${RETVAL}%{%f%b%} "
  else
    echo -n "${RETVAL} "
  fi
}

prompt_context() {
  [[ "$_me" = "false" ]] && u="${USERNAME}@"
  echo -n "${u}%m(%35<...<%~) "
}

prompt_git() {
  local color

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

prompt_end() {
  echo -n "%# "
}

build_prompt() {
  RETVAL=$?

  # first optional line
  prompt_git_status
  git_rc=$?
  prompt_rack_env
  rack_rc=$?

  if [[ $git_rc -eq 1 || $rack_rc -eq 1 ]]; then
    echo ""
  fi

  # actual prompt
  prompt_rc
  prompt_context
  prompt_end
}

setopt prompt_subst

PROMPT='%{%f%b%k%}$(build_prompt)'
