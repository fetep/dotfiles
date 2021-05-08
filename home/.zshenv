# sourced on every zsh invocation except if -f is given.

typeset -Ug path

if [[ -d ~/.local/bin ]]; then
  path=(~/.local/bin "$path[@]")
fi

if [[ -d ~/bin ]]; then
  path=(~/bin "$path[@]")
fi

path+=(/usr/local/bin)
path+=(/usr/bin)
path+=(/bin)
path+=(/usr/local/sbin)
path+=(/usr/sbin)
path+=(/sbin)

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
READNULLCMD=$PAGER

# vi
if [[ -x =vim ]]; then
  export EDITOR="vim"
else
  export EDITOR="vi"
fi

export VISUAL="$EDITOR"

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
