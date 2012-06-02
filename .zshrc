
umask 022

setopt rm_star_silent
setopt interactivecomments
setopt no_prompt_cr
setopt notify
setopt vi
setopt shwordsplit
setopt autopushd
setopt pushd_ignore_dups
setopt nohup
setopt extendedglob
setopt nocorrect

# history
setopt append_history
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
HISTFILE=~/.history_zsh
HISTSIZE=1048576
SAVEHIST=$HISTSIZE

# aliases
alias ls='ls -F'
alias d='dirs -v'
alias pushd='pushd; dirs -v'
alias popd='popd; dirs -v'
alias vi=vim
alias -g L='|less'
alias -g H='|head'
alias -g T='|tail'
alias ack='ack-grep'
alias t='mkdir -m 0700 -p /tmp/$USER.$$; cd /tmp/$USER.$$'
alias pi='ssh -t people.mozilla.com screen -x irc'
unalias rm mv cp 2>/dev/null  # no -i madness

if [ ! -z "$REAL_USER" ]; then
  alias vim="env HOME=/home/$REAL_USER vim"
fi

# ksh addictions
setopt nonomatch
bindkey "\e_" insert-last-word
bindkey "\e*" expand-word
bindkey "\e=" list-expand
bindkey -r "\e/" # let the vi keymap pick this up
bindkey -M vicmd k vi-up-line-or-history
bindkey -M vicmd j vi-down-line-or-history
bindkey -M viins '^r' history-incremental-search-backward
bindkey -M vicmd '^r' history-incremental-search-backward
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# completion madness
compctl -g '*(-/D)' cd
compctl -g '*.ps' ghostview gv evince
compctl -g '*.pdf' acroread xpdf evince
compctl -j -P '%' kill bg fg
compctl -v export unset vared

# some variables for later
HOST="$(hostname)"
HOST="${HOST%%.*}"

# common path to an ssh agent
export LOCAL_SSH_AUTH_SOCK=/tmp/$USER.ssh-agent.sock

# if we don't have keys locally, point the "local" ssh-agent
# sock path at our forwarded agent
if [ ! -e "$HOME/.ssh/id_dsa"  -a \
     -n "$SSH_AUTH_SOCK" -a \
     "$SSH_AUTH_SOCK" != "$LOCAL_SSH_AUTH_SOCK" ]; then
  export REAL_SSH_AUTH_SOCK=$SSH_AUTH_SOCK
  ln -sf $REAL_SSH_AUTH_SOCK $LOCAL_SSH_AUTH_SOCK
fi

export SSH_AUTH_SOCK=$LOCAL_SSH_AUTH_SOCK

if [ -e "$HOME/.ssh/id_dsa" ]; then
  # Do we need to start an agent or add keys?
  ssh-add -l >/dev/null 2>&1
  rc=$?
  if [ $rc -eq 2 ]; then
    ssh-agent -a $SSH_AUTH_SOCK
    flock -nx /tmp/$USER.ssh-add ssh-add
  elif [ $rc -eq 1 ]; then
    flock -nx /tmp/$USER.ssh-add ssh-add
  fi
fi

if [ -s "$HOME/.rvm/scripts/rvm" ]; then
  source $HOME/.rvm/scripts/rvm
fi

function psg() {
  ps auxww | egrep -- $* | fgrep -v egrep
}

function svn-tkdiff() {
  svn st -q "$@" | while read mod file; do
    if [ ! -f "$file" ]; then
      continue
    fi
    if [ "$mod" = "A" ]; then
      echo "$file (NEW)"
      tkdiff /dev/null $file
    else
      echo "$file (MOD)"
      tkdiff $file
    fi
  done
}

function title() {
  # This is madness.
  # We replace literal '%' with '%%'
  # Also use ${(V) ...} to make nonvisible chars printable (think cat -v)
  # Replace newlines with '; '
  local value="${${${(V)1//\%/\%\%}//'\n'/; }//'\t'/ }"
  local location

  location="${HOST}(%55<...<%~)"
  [ "$USERNAME" != "$LOGNAME" ] && location="${USERNAME}@${location}"

  # Special format for use with print -Pn
  value="%70>...>$value%<<"
  unset PROMPT_SUBST
  case $TERM in
    screen*)
      # Put this in your .screenrc:
      # hardstatus string "[%n] %h - %t"
      # termcapinfo xterm 'hs:ts=\E]2;:fs=\007:ds=\E]2;screen (not title yet)\007'
      print -Pn "\ek${value}\e\\"     # screen title (in windowlist)
      print -Pn "\e_${location}\e\\"  # screen location
      ;;
    xterm*)
      print -Pn "\e]0;${value} - ${location}\a"
      ;;
  esac
  setopt LOCAL_OPTIONS
}

function precmd() {
  title "zsh"
}

function preexec() {
  # The full command line comes in as "$1"
  local cmd="$1"
  local -a args

  # add '--' in case $1 is only one word to work around a bug in ${(z)foo}
  # in zsh 4.3.9.
  tmpcmd="$1 --"
  args=${(z)tmpcmd}

  # remove the '--' we added as a bug workaround..
  # per zsh manpages, removing an element means assigning ()
  # TODO: support fg %-
  args[${#args}]=()
  if [ "${args[1]}" = "fg" ] ; then
    local jobnum="${args[2]}"
    if [ -z "$jobnum" ] ; then
      # If no jobnum specified, find the current job.
      for i in ${(k)jobtexts}; do
        [ -z "${jobstates[$i]%%*:+:*}" ] && jobnum=$i
      done
    fi
    cmd="${jobtexts[${jobnum#%}]}"
  else
  fi
  title "$cmd"
}

function rand() {
  RANDOM=$RANDOM`date +%s`        # seed
  while IFS= read -r in
  do
    echo ${RANDOM}${RANDOM} "$in"
  done < ${1:-/dev/stdin} | sort | sed -e 's,^[0-9]* ,,'
}

function bytes() {
  if [ $# -gt 0 ]; then
    while [ $# -gt 0 ]; do
      echo -n "${1}B = "
      byteconv "$1"
      shift
    done
  else
    while read a; do
      byteconv "$a"
    done
  fi
}

function byteconv() {
  a=$1
  ORDER=BKMGTP
  while [ $(echo "$a >= 1024" | bc) -eq 1 -a $#ORDER -gt 1 ]; do
    a=$(echo "scale=2; $a / 1024" | bc)
    ORDER="${ORDER#?}"
  done
  echo "${a}${ORDER[0]}"
}

function up() {
  target=""
  for ((i=0; i < ${1:-1}; i++)) {
    target="${target}../"
  }
  cd ${target}${2}
}

function stats() {
  gawk '
    {
      total += $1;
      if ($1 < min) min = $1;
      if ($1 > max) max = $1;
      input[FNR] = $1
    }
    END {
      mean = total / NR;

      d = 0;
      for (i in input) {
        n = input[i];
        d += (n - mean) ** 2;
      }
      variance = d / NR;
      d /= NR - 1;
      stddev = sqrt(d);

      low_outliers = 0;
      high_outliers = 0;
      for (i in input) {
        n = input[i];
        if (n >= (mean + (2 * stddev))) high_outliers += 1;
        if (n <= (mean - (2 * stddev))) low_outliers += 1;
      }
      total_outliers = low_outliers + high_outliers;

      asort(input);
      if (NR % 2 == 0) {
        n1 = NR / 2;
        n2 = n1 + 1;
        median = (input[n1] + input[n2]) / 2;
      } else {
        n1 = (NR + 1) / 2;
        median = input[n1];
      }

      printf "min: %g\n", min;
      printf "max: %g\n", max;
      printf "range: %g\n", max - min;
      printf "mean: %g\n", mean;
      printf "median: %g\n", median;
      printf "variance: %g\n", variance;
      printf "stddev: %g\n", stddev;
      printf "outliers: %g", total_outliers;
      if (total_outliers > 0) {
        printf " (%d high, %d low)", high_outliers, low_outliers;
      }
      printf "\n";
    }
  '
}

function pastebin() {
  curl --data-urlencode "paste_code@${1:--}" http://pastebin.com/api_public.php
  echo ""  # API doesn't return a newline
}

. ~/.zshenv
