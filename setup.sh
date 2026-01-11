#!/usr/bin/env bash
# symlink files in $HOME to this checkout
# if any existing files are there, we save them in ./backup

set -euo pipefail
progname="${0##*/}"

log() {
  echo "$progname: ""$@"
}

cd "$(dirname "$0")"
base=$PWD
backdir="$base/backup"

mkdir -p -m 0700 "$backdir"

# update submodules on a fresh checkout
git submodule init
git submodule update --recursive

link() {
  local dotfile="$1" dotdir="$2"
  local dotpath="$(dirname "$dotfile")"

  if [[ -e "$HOME/$dotfile" && ! -L "$HOME/$dotfile" ]]; then
    mkdir -p "$backdir/$dotpath"
    log "backing up $HOME/$dotfile to $backdir/$dotfile"
    mv "$HOME/$dotfile" "$backdir/$dotfile"
  fi

  link_target="$dotdir/$dotfile"
  if [[ -L "$HOME/$dotfile" ]]; then
    existing="$(readlink -f "$HOME/$dotfile")"
    if [[ "$existing" != "$link_target" ]]; then
      log "swapping $HOME/$dotfile from $existing to $link_target"
      ln -sf "$link_target" "$HOME/$dotfile"
    fi
  else
    mkdir -p "$HOME/$dotpath"
    log "linking $HOME/$dotfile to $dotdir/$dotfile"
    ln -s "$dotdir/$dotfile" "$HOME/$dotfile"
  fi
}

link_dir() {
  local dotdir="$1" srcbase="$2"
  local dotpath="$(dirname "$dotdir")"
  local link_target="$srcbase/$dotdir"

  if [[ "$dotpath" != "." ]]; then
    mkdir -p "$HOME/$dotpath"
  fi

  if [[ -L "$HOME/$dotdir" ]]; then
    existing="$(readlink -f "$HOME/$dotdir")"
    if [[ "$existing" != "$link_target" ]]; then
      log "swapping $HOME/$dotdir from $existing to $link_target"
      ln -sfn "$link_target" "$HOME/$dotdir"
    fi
  elif [[ -d "$HOME/$dotdir" ]]; then
    mkdir -p "$backdir/$dotpath"
    log "backing up $HOME/$dotdir to $backdir/$dotdir"
    mv "$HOME/$dotdir" "$backdir/$dotdir"
    log "linking $HOME/$dotdir to $link_target"
    ln -s "$link_target" "$HOME/$dotdir"
  else
    log "linking $HOME/$dotdir to $link_target"
    ln -s "$link_target" "$HOME/$dotdir"
  fi
}

dir_symlinks=(.zsh .config/nvim)

link_dotdir() {
  local dotdir="$1"
  local excludes=()
  for d in "${dir_symlinks[@]}"; do
    excludes+=(-path "./$d" -prune -o -path "./$d/*" -prune -o)
  done
  (cd "$dotdir" && find . "${excludes[@]}" -type f \! -path '*/.*.sw*' -print0) |
  while IFS= read -r -d '' dotfile; do
    link "${dotfile##./}" "$dotdir"
  done
}

link_dotdirs() {
  local srcbase="$1"
  for d in "${dir_symlinks[@]}"; do
    if [[ -d "$srcbase/$d" ]]; then
      link_dir "$d" "$srcbase"
    fi
  done
}

is_workstation() {
  local ws="false"
  if hostname | grep -F -q fetep.net; then
    ws="true"
  fi

  if [[ -e ~/.ws ]]; then
    ws="true"
  fi

  echo "$ws"
}

echo "=> linking dotfiles in $base/home"
link_dotdirs "$base/home"
link_dotdir "$base/home"

if [[ $(is_workstation) == "true" ]]; then
  echo "=> linking workstation dotfiles in $base/home-ws"
  link_dotdirs "$base/home-ws"
  link_dotdir "$base/home-ws"
fi

if command -v brew >/dev/null; then
  make -C brew
fi
