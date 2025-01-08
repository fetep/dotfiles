# sourced on every zsh invocation except if -f is given.

typeset -Ug path

if [[ -d ~/bin ]]; then
  path=(~/bin "$path[@]")
fi

if [[ -d ~/.local/bin ]]; then
  path=(~/.local/bin "$path[@]")
fi

for dir in /usr/local/{s,}bin /usr/{s,}bin /{s,}bin /var/lib/snapd/snap/bin /usr/local/node/bin; do
  [[ -d "$dir" ]] && path+=("$dir")
done

unset dir

# force ssh
export CVS_RSH=ssh
export RSYNC_RSH=ssh

# pager
if [[ -x =less ]]; then
  export PAGER=less
  export LESS="-niXR"
else
  export PAGER=more
fi
READNULLCMD="$PAGER"
export SYSTEMD_PAGER="$PAGER"
export SYSTEMD_LESS="$LESS"

# term fix-ups
if [[ "$TERM" = "screen-bce" ]]; then
  export TERM="screen"
fi

# add rvm to path for scripting
if [[ -d "$HOME/.rvm" ]]; then
  path+=("$HOME/.rvm/bin")
fi

# misc
unset GNOME_KEYRING_CONTROL
export RIPGREP_CONFIG_PATH=~/.ripgreprc
export LC_TIME="en_GB.UTF-8"

[[ -e "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
