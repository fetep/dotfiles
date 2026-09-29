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
update_submodules() {
  local repo="$1"

  (cd "$repo" && git submodule init && git submodule update --recursive)
}

update_submodules "$base"

link() {
  local dotfile="$1" dotdir="$2"
  local dotpath="$(dirname "$dotfile")"

  if [[ -e "$HOME/$dotfile" && ! -L "$HOME/$dotfile" ]]; then
    mkdir -p "$backdir/$dotpath"
    log "backing up $HOME/$dotfile to $backdir/$dotfile"
    mv "$HOME/$dotfile" "$backdir/$dotfile"
  fi

  link_target="$(readlink -f "$dotdir/$dotfile")"
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

# Later source directories have precedence over earlier ones.
has_higher_priority_file() {
  local dotfile="$1" srcbase
  shift
  for srcbase in "$@"; do
    [[ -f "$srcbase/$dotfile" || -L "$srcbase/$dotfile" ]] && return 0
  done
  return 1
}

link_dotdir() {
  local dotdir="$1" dotfile
  shift
  local excludes=()
  for d in "${dir_symlinks[@]}"; do
    excludes+=(-path "./$d" -prune -o -path "./$d/*" -prune -o)
  done
  (cd "$dotdir" && find . "${excludes[@]}" \( -type f -o -type l \) \! -path '*/.*.sw*' -print0) |
  while IFS= read -r -d '' dotfile; do
    dotfile="${dotfile##./}"
    has_higher_priority_file "$dotfile" "$@" || link "$dotfile" "$dotdir"
  done
}

merge_dotdir() {
  local dotdir="$1" mergedbase="$2"
  shift 2
  local sources=("$@")
  local srcbase dotfile dotpath target i

  mkdir -p "$mergedbase/$dotdir"

  for ((i = 0; i < ${#sources[@]}; i++)); do
    srcbase="${sources[i]}"
    [[ -d "$srcbase/$dotdir" ]] || continue
    (cd "$srcbase/$dotdir" && find . \( -type f -o -type l \) \! -path '*/.*.sw*' -print0) |
    while IFS= read -r -d '' dotfile; do
      dotfile="${dotfile##./}"
      has_higher_priority_file "$dotdir/$dotfile" "${sources[@]:i+1}" && continue
      dotpath="$(dirname "$dotfile")"
      target="$srcbase/$dotdir/$dotfile"
      mkdir -p "$mergedbase/$dotdir/$dotpath"
      if [[ ! -L "$mergedbase/$dotdir/$dotfile" || "$(readlink "$mergedbase/$dotdir/$dotfile")" != "$target" ]]; then
        ln -sfn "$target" "$mergedbase/$dotdir/$dotfile"
      fi
    done
  done

  (cd "$mergedbase/$dotdir" && find . -type l -print0) |
  while IFS= read -r -d '' dotfile; do
    dotfile="${dotfile##./}"
    if ! has_higher_priority_file "$dotdir/$dotfile" "${sources[@]}"; then
      rm "$mergedbase/$dotdir/$dotfile"
    fi
  done
  find "$mergedbase/$dotdir" -mindepth 1 -depth -type d -empty -delete

  link_dir "$dotdir" "$mergedbase"
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

workstation="$(is_workstation)"
overlay="${DOTFILES_OVERLAY-}"
source_dirs=("$base/home")

if [[ "$workstation" == "true" ]]; then
  source_dirs+=("$base/home-ws")
fi

if [[ -n "$overlay" && -d "$overlay" ]]; then
  overlay="$(cd "$overlay" && pwd)"
  [[ -e "$overlay/.git" ]] && update_submodules "$overlay"
  [[ -d "$overlay/home" ]] && source_dirs+=("$overlay/home")
  if [[ "$workstation" == "true" && -d "$overlay/home-ws" ]]; then
    source_dirs+=("$overlay/home-ws")
  fi
  echo "=> applying private overlay from $overlay"
fi

for ((i = 0; i < ${#source_dirs[@]}; i++)); do
  srcbase="${source_dirs[i]}"
  echo "=> linking dotfiles in $srcbase"
  link_dotdir "$srcbase" "${source_dirs[@]:i+1}"
done

for d in "${dir_symlinks[@]}"; do
  overlay_has_dir="false"
  if [[ -n "$overlay" && -d "$overlay" ]]; then
    [[ -d "$overlay/home/$d" ]] && overlay_has_dir="true"
    if [[ "$workstation" == "true" && -d "$overlay/home-ws/$d" ]]; then
      overlay_has_dir="true"
    fi
  fi

  if [[ "$overlay_has_dir" == "true" ]]; then
    merge_dotdir "$d" "$backdir/merged-home" "${source_dirs[@]}"
  else
    for srcbase in "${source_dirs[@]}"; do
      [[ -d "$srcbase/$d" ]] && link_dir "$d" "$srcbase"
    done
  fi
done

if command -v brew >/dev/null; then
  make -C brew
fi
