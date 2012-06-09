# sourced on every zsh invocation except if -f is given.

PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
NEWPATH=$HOME/bin
for p in /usr/ucb /usr/ccs/bin /opt/SUNWspro/bin /opt/gnu/bin /var/lib/gems/1.8/bin /usr/lib/gems/1.8/bin $HOME/android/android-sdk-linux/tools $HOME/android/android-sdk-linux/platform-tools $HOME/.rvm/bin
do
  [ -d "$p" ] && NEWPATH=$NEWPATH:$p
done
export PATH=$NEWPATH:$PATH

for p in /usr/man /usr/share/man /usr/local/man
do
  [ -d "$p" ] && MANPATH=$MANPATH:$p
done
export MANPATH
unset p

# ssh
export CVS_RSH=ssh
export RSYNC_RSH=ssh

# pager
if [ _`whence less` != '_' ]; then
  export PAGER=less
  export LESS="-niX"
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
