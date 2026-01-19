# tell git to never look outside of our homedir for a .git
GIT_CEILING_DIRECTORIES=$HOME/..
export GIT_CEILING_DIRECTORIES=${GIT_CEILING_DIRECTORIES:A}

# set env vars for other git-related functions to use. this way we run
# the git commands only once.
update-git-vars() {
  local inside
  inside="$(command git rev-parse --is-inside-work-tree 2>/dev/null)"
  if [[ $inside != "true" ]]; then
    unset _git_ref _git_root _git_repo
    return 0
  fi

  _git_ref=$(git_ref)
  _git_root="$(git rev-parse --show-toplevel)"

  # pick a short "repo name" for use in our prompt, the basename of our git root
  # if we're in a worktree layout, treat the bare path as the git root
  local repo_path
  repo_path="$(git worktree list | awk '$2 == "(bare)" {print $1;}')"
  [[ -z "$repo_path" ]] && repo_path="$PWD"
  _git_repo="${repo_path##*/}"
}

add-zsh-hook precmd update-git-vars

git_default_branch() {
  if [[ -z "$_git_ref" ]]; then
    echo "git_default_branch: not in a git repo" >&2
    return 1
  fi

  local branch
  branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
  [[ -z "$branch" ]] && branch=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')

  if [[ -z "$branch" ]]; then
    echo "git_default_branch: can't determine default branch" >&2
    return 2
  fi

  echo "$branch"
}

git_worktree_root() {
  if [[ -z "$_git_ref" ]]; then
    echo "git_worktree_root: not in a git repo" >&2
    return 1
  fi

  if ! git worktree list | grep -Fq "(bare)"; then
    echo "git_worktree_root: not in a worktree layout" >&2
    return 2
  fi

  (cd "${_git_root}/.." && pwd)
}

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

# some custom git sub-commands; this way we don't have to carry around
# ~/bin/git-* scripts.
git() {
  local cmd=$1
  shift

  case $cmd in
    backup)
      git-backup "$@"
      ;;
    branch-cleanup)
      git-branch-cleanup "$@"
      ;;
    push-n)
      git-pushn "$@"
      ;;
    worktree-new)
      git-worktree-new "$@"
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

  local repo_checkout="$(basename "$_git_root")"
  local repo_parent="$(dirname "$_git_root")"
  local tar_name="${repo_checkout}-$(date +%Y%m%d%H%M).tgz"

  echo "=> Creating ${repo_parent}/${tar_name}" >&2
  (cd "${repo_parent}" && tar czf "${tar_name}" "${repo_checkout}")
}

git-branch-cleanup() {
  if [[ -z "$_git_ref" ]]; then
    echo "git-branch-cleanup: not in a git repo" >&2
    return 1
  fi

  local branch default_branch="$(git_default_branch)"
  [[ $? -eq 0 ]] || return 1

  git branch --merged "$default_branch" 2>/dev/null | grep -v '^[*+]' | grep -v "^\s*$default_branch$" | \
    while read branch; do
      echo "=> removing branch $branch (merged)"
      git branch -d "$branch" || return 2
    done
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

# convert the current git checkout to a worktree layout
git-worktree-convert() {
  if [[ -z "$_git_ref" ]]; then
    echo "git-worktree-convert: not in a git repo" >&2
    return 1
  fi

  # make sure we're not in a worktree setup already
  if git worktree list | grep -Fq "(bare)"; then
    echo "git-worktree-convert: already in a worktree layout" >&2
    return 2
  fi

  local default_branch="$(git_default_branch)" origin="$(git remote get-url origin)"
  local git_checkout="$(basename "$_git_root")"

  if [[ -e "../${git_checkout}.old" ]]; then
    echo "git-worktree-convert: can't back up, ${git_checkout}.old already exists" >&2
    return 3
  fi

  gcd ..
  mv "$git_checkout" "${git_checkout}.old" || return 3
  mkdir "$git_checkout"
  cd "$git_checkout" || return 3

  git clone --bare "$origin" .git
  git worktree add "$default_branch"
  zoxide add "$default_branch"
  git worktree add review
  zoxide add review
}

git-worktree-new() {
  if [[ -z "$_git_ref" ]]; then
    echo "git-worktree-new: not in a git repo" >&2
    return 1
  fi

  if ! git worktree list | grep -Fq "(bare)"; then
    echo "git-worktree-new: not in a worktree layout" >&2
    return 2
  fi

  if [[ $# -ne 1 ]]; then
    echo "usage: git-worktree-new <name>" >&2
    return 3
  fi

  local branch=$_git_ref worktree_root="$(git_worktree_root)"

  if [[ -e "$worktree_root/$1" ]]; then
    echo "git-worktree-new: $1: worktree already exists" >&2
    return 4
  fi

  cd "$worktree_root"
  git worktree add -b "petef/$1" "$1"
  zoxide add "$1"
  cd -

  sesh connect "$worktree_root/$1"
}
alias nb=git-worktree-new # "new branch"

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
