# sourced on every zsh invocation except if -f is given.

# path
typeset -U path
path=(~/bin "$path[@]")
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
if [ -x =less ]; then
  export PAGER=less
  export LESS="-niXR"
else
  export PAGER=more
fi
READNULLCMD=$PAGER

# vi
export EDITOR="vim"
export VISUAL="$EDITOR"

# mysql
export MYSQL_PS1="\u@\h[\d] => "

# use screen-256color on modern OSes
if [ "$TERM" = "screen-bce" ]; then
  export TERM="screen"
fi

# i'm sure there's a better way to do this.
if [ "$TERM" = "screen" ]; then
  case $(uname -s) in
  Linux)
    case $(cat /etc/redhat-release 2>/dev/null) in
    *release\ 6*|*release\ 7*)
      export TERM=screen-256color
      ;;
    esac
    ;;
  FreeBSD)
    case $(uname -r) in
    10*)
      export TERM=screen-256color
      ;;
    esac
    ;;
  esac
fi
