#!/usr/bin/env bash
# symlink files in $HOME to this checkout
# if any existing files are there, we save them in ./backup

progname=$(basename $0)

err() {
  log "$@" >&2
}

log() {
  echo "$progname: ""$@"
}

base=$(readlink -f $(dirname $0))
backdir="$base/backup"
dotdir="$base/home"

mkdir -p -m 0700 "$backdir"

find "$dotdir" -type f | sed -e "s,^$dotdir/,," |
while read dotfile; do
  dotpath=$(dirname $dotfile)

  if [[ -e "$HOME/$dotfile" && ! -L "$HOME/$dotfile" ]]; then
    mkdir -p "$backdir/$dotpath"
    log "backing up $HOME/$dotfile to $backdir/$dotfile"
    mv "$HOME/$dotfile" "$backdir/$dotfile"
  fi

  link_target="$dotdir/$dotfile"
  if [[ -L "$HOME/$dotfile" ]]; then
    existing=$(readlink -f "$HOME/$dotfile")
    if [[ $existing != $link_target ]]; then
      log "swapping $HOME/$dotfile from $existing to $link_target"
      ln -sf "$link_target" "$HOME/$dotfile"
    fi
  else
    mkdir -p "$HOME/$dotpath"
    log "linking $HOME/$dotfile to $dotdir/$dotfile"
    ln -s "$dotdir/$dotfile" "$HOME/$dotfile"
  fi
done
