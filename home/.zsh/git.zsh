# tell git to never look outside of our homedir for a .git
GIT_CEILING_DIRECTORIES=$HOME/..
export GIT_CEILING_DIRECTORIES=${GIT_CEILING_DIRECTORIES:A}

# set env vars for other git-related functions to use. this way we run
# the git commands only once.
update-git-vars() {
  local inside
  inside="$(command git rev-parse --is-inside-work-tree 2>/dev/null)"
  if [[ $inside != "true" ]]; then
    unset _git_ref
    return 0
  fi

  _git_ref=$(git_ref)
}

add-zsh-hook precmd update-git-vars

git_ref() {
  local ref=$(git symbolic-ref HEAD 2>/dev/null ||
              git show-ref --head -s --abbrev 2>/dev/null | head -n 1)
  echo "${ref/refs\/heads\//}"
}

# git push alias
p() {
  local cmd

  if [[ -z "$_git_ref" ]]; then
    echo "p: not in a git repo" >&2
    return 1
  fi

  if [[ $1 = "-n" ]]; then
    cmd="git push-n origin $_git_ref"
  elif [[ $1 = "-f" ]]; then
    # don't ever force push a branch other than $USERNAME/
    if [[ ! $_git_ref =~ ^${USER}/ ]]; then
      echo "p: won't force push a non-personal branch ($_git_ref)" >&2
      return 2
    fi
    cmd="git push -f origin $_git_ref"
  else
    cmd="git push origin $_git_ref"
  fi

  echo "=> $cmd" >&2
  $cmd
}

# git status alias
s() {
  if [[ -z "$_git_ref" ]]; then
    echo "s: not in a git repo" >&2
    return 1
  fi

  git status "$@"
}

# git update alias
u() {
  local cmd

  if [[ -z "$_git_ref" ]]; then
    echo "u: not in a git repo" >&2
    return 1
  fi

  cmd="git fetch -p origin"
  echo "=> $cmd" >&2
  $cmd

  # TODO: figure out if we need to stash/rebase/stash apply
  cmd="git rebase origin/$_git_ref"
  echo "=> $cmd" >&2
  $cmd
}

# cd to git root
gr() {
  if [[ -z "$_git_ref" ]]; then
    echo "gr: not in a git repo" >&2
    return 1
  fi

  local repo_path=$(git rev-parse --show-toplevel)
  cd "$repo_path"
}

# some custom git sub-commands; this way we don't have to carry around
# ~/bin/git-* scripts.
git() {
  local cmd=$1
  shift

  case $cmd in
    backup)
      git-backup "$@"
      ;;
    push-n)
      git-pushn "$@"
      ;;
    *)
      command git $cmd "$@"
      ;;
  esac
}

git-backup() {
  if [[ -z "$_git_ref" ]]; then
    echo "git-backup: not in a git repo" >&2
    return 1
  fi

  local repo_path=$(git rev-parse --show-toplevel)
  local repo_checkout=$(basename "$repo_path")
  local repo_topdir=$(dirname "$repo_path")
  local tar_name="${repo_checkout}-$(date +%Y%m%d%H%M).tgz"

  echo "=> Creating ${repo_topdir}/${tar_name}" >&2
  (cd "${repo_topdir}" && tar czf "${tar_name}" "${repo_checkout}")
}

git-pushn() {
  if [[ -z "$_git_ref" ]]; then
    echo "git-pushn: not in a git repo" >&2
    return 1
  fi

  local output="$(git push -n "$@" 2>&1)"
  local git_rc=$?

  echo "$output" >&2

  range=$(
    echo $output |
    sed -n -r -e 's,^.* ([0-9a-f]+\.\.[0-9a-f]+).*,\1,p'
  )

  if [[ -n "$range" ]]; then
    git log $range
  fi

  return $git_rc
}

# Git cd: no args takes you to the repo root, any other
# directory arg is considered relative to the repo root
gcd() {
  if [[ -z "$_git_ref" ]]; then
    echo "gcd: not in a git repo" >&2
    return 1
  fi

  cd "$(git rev-parse --show-toplevel)"
  [[ $# -gt 0 ]] && cd "$@"
}
