# $Id: .zshenv 30 2010-07-19 21:22:09Z petef $
#
# sourced on every zsh invocation except if -f is given.
#

export KVDB=/home/petef/m/sysadmins/svc/kv/kvdb

PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
NEWPATH=$HOME/bin
for p in /usr/ucb /usr/ccs/bin /opt/SUNWspro/bin /opt/gnu/bin /var/lib/gems/1.8/bin /home/petef/ops/scripts /home/petef/android/android-sdk-linux/tools /home/petef/android/android-sdk-linux/platform-tools /home/petef/kv/bin
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

[ "$USERNAME" != "petef" -a "$USERNAME" != "root" ] && u="${USERNAME}@"
export PS1="%? ${u}%m(%35<...<%~) %# "
unset RPROMPT RPS1

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
