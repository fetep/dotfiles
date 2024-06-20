#!/usr/bin/env bash
# symlink files in $HOME to this checkout
# if any existing files are there, we save them in ./backup

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

link_dotdir() {
  local dotdir="$1"
  (cd "$dotdir" && find . -type f \! -path '*/.*.sw*' -print0) |
  while IFS= read -r -d '' dotfile; do
    link "${dotfile##./}" "$dotdir"
  done
}

echo "=> linking dotfiles in $base/home"
link_dotdir "$base/home"

# separate workstation dotfiles into home-ws
if hostname | grep -F -q fetep.net; then
  echo "=> linking workstation dotfiles in $base/home-ws"
  link_dotdir "$base/home-ws"
fi
