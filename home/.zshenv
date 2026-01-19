# sourced on every zsh invocation except if -f is given.
# general
umask 022
HOST="${$(hostname)%%.*}"

# path management
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

# pager
if (( $+commands[less] )); then
  export PAGER=less
  export LESS="--line-numbers --ignore-case --no-init --RAW-CONTROL-CHARS --quit-if-one-screen"
else
  export PAGER=more
fi
READNULLCMD="$PAGER"
export SYSTEMD_PAGER="$PAGER"
export SYSTEMD_LESS="$LESS"

# misc
export BUILDKIT_PROGRESS=plain
export RIPGREP_CONFIG_PATH=~/.ripgreprc
export LC_TIME="en_GB.UTF-8"

[[ -e "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

if [[ -n $TMUX ]]; then
  _tmux_session=$(tmux display-message -p '#S')
fi

autoload -U add-zsh-hook
autoload -U compinit
compinit

for file in $HOME/.zsh/env/*.zsh(N); do
  . $file
done
