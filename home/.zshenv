# sourced on every zsh invocation except if -f is given.

typeset -Ug path

# prepend path
for dir in ~/.local/bin ~/bin; do
  [[ -d "$dir" ]] && path=("$dir" "$path[@]")
done

# append path
for dir in \
  /{s,}bin \
  /usr/{s,}bin \
  /usr/local/{s,}bin \
  {/var/lib/snapd/snap,/snap}/bin \
  $HOME/.cargo/bin \
  /opt/puppetlabs/{,/puppet}/bin; do
  [[ -e "$dir" ]] && path+=("$dir")
done

unset dir

# force ssh
export CVS_RSH=ssh
export RSYNC_RSH=ssh

# pager
if [[ -x =less ]]; then
  export PAGER=less
  export LESS="--line-numbers --ignore-case --no-init --RAW-CONTROL-CHARS"
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
export BUILDKIT_PROGRESS=plain
export RIPGREP_CONFIG_PATH=~/.ripgreprc
export LC_TIME="en_GB.UTF-8"

[[ -e "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
