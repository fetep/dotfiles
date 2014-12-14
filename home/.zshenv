# sourced on every zsh invocation except if -f is given.

PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
NEWPATH=$HOME/bin
#for p in /usr/ucb /usr/ccs/bin /opt/SUNWspro/bin /opt/gnu/bin
#do
#  [ -d "$p" ] && NEWPATH=$NEWPATH:$p
#done
export PATH=$NEWPATH:$PATH

# ssh
export CVS_RSH=ssh
export RSYNC_RSH=ssh

# pager
if [ _`whence less` != '_' ]; then
  export PAGER=less
  export LESS="-niXR"
else
  export PAGER=more
fi
READNULLCMD=$PAGER

# vi
export EDITOR="vim"
export VISUAL="$EDITOR"

if [ "$TERM" = "screen-bce" ]; then
  export TERM="screen"
fi

unset GNOME_KEYRING_CONTROL

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
