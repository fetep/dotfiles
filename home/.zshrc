# general
umask 022
HOST="${$(hostname)%%.*}"

case $USER in
petef*|pfritchman|pf*) _me=true ;;
*) _me=false ;;
esac

if [[ -n $TMUX ]]; then
  _tmux_session=$(tmux display-message -p '#S')
fi

# vi mode, inspired by ksh
setopt vi
setopt nonomatch
bindkey "\e_" insert-last-word
bindkey "\e*" expand-word
bindkey "\e=" list-expand
bindkey -r "\e/" # let the vi keymap pick this up
bindkey -M viins '^r' history-incremental-search-backward
bindkey -M vicmd '^r' history-incremental-search-backward
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# options
setopt rm_star_silent
setopt interactivecomments
setopt no_prompt_cr
setopt notify
setopt shwordsplit
setopt autopushd
setopt pushd_ignore_dups
setopt nohup
setopt extendedglob
setopt nocorrect
setopt prompt_cr
setopt prompt_sp

# history
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt hist_ignore_space
setopt share_history
if [[ "$_me" == "true" ]]; then
    HISTFILE=$HOME/.history_zsh
else
    HISTFILE=$HOME/.history_zsh_$USER
fi
HISTSIZE=1048576
SAVEHIST=$HISTSIZE

# shell-local history search
vi-up-line-or-local-history() {
  zle set-local-history 1
  zle vi-up-line-or-history
  zle set-local-history 0
}

vi-down-line-or-local-history() {
  zle set-local-history 1
  zle vi-down-line-or-history
  zle set-local-history 0
}

zle -N vi-up-line-or-local-history
zle -N vi-down-line-or-local-history
bindkey -M vicmd k vi-up-line-or-local-history
bindkey -M vicmd j vi-down-line-or-local-history

# aliases
for n in {1..9}; do alias ${n}="cd +${n}"; done
alias -g L='|less'
[[ -x =ack-grep ]] && alias ack='ack-grep'
alias be='bundle exec'
alias d='dirs -v'
alias ls='ls -F --color'
alias popd='popd; dirs -v'
alias pushd='pushd; dirs -v'
alias t='mkdir -m 0700 -p /tmp/$USER.$$ && cd /tmp/$USER.$$'
alias tmux='tmux -2'
unalias rm mv cp 2>/dev/null  # no -i madness

# configure editor
if (( $+commands[nvim] )); then
  alias vi=nvim
  export EDITOR=nvim
elif (( $+commands[vim] )); then
  alias vi=vim
  export EDITOR=vim
else
  export EDITOR=vi
fi
export VISUAL="$EDITOR"

# completion madness
compctl -g '*(-/D)' cd
compctl -g '*.ps' ghostview gv evince
compctl -g '*.pdf' acroread xpdf evince
compctl -j -P '%' kill bg fg
compctl -v export unset vared

autoload -U add-zsh-hook
autoload -U compinit
compinit

# systems with older ncurses don't know about alacritty
if [[ $TERM == "alacritty" ]]; then
  if ! infocmp alacritty >/dev/null 2>&1; then
    export TERM=xterm-256color
  fi
fi

# custom functions
function psg() {
  ps auxww | egrep -i -- "$@" | fgrep -v -- "egrep -i --"
}

function scp() {
  remote=false
  for arg; do
    if [[ "${arg%%:*}" != "${arg}" ]]; then
      remote=true
      break
    fi
  done

  if ! $remote; then
    echo "scp: no remote location specified" >&2
    return 1
  fi

  =scp "$@"
}

function title() {
  # This is madness.
  # We replace literal '%' with '%%'
  # Also use ${(V) ...} to make nonvisible chars printable (think cat -v)
  # Replace newlines with '; '
  local cmd="${${${(V)1//\%/\%\%}//'\n'/; }//'\t'/ }"
  local curdir="(%30<...<%~)"
  local location="${HOST}"

  $_me || location="${USERNAME}@${location}"
  if [[ -n $_tmux_session ]]; then
    local tmux="[$_tmux_session] "
  fi

  cmd="%$((COLUMNS-30))>...>$cmd%<<"
  unset PROMPT_SUBST
  case $TERM in
    screen*)
      if [[ -n "$TMUX" ]]; then
        if [[ $1 == "-zsh" || $1 == "zsh" ]]; then
          print -Pn "\ek \e\\"                    # window_name (empty)
        else
          print -Pn "\ek${cmd}\e\\"               # window_name
        fi
        print -Pn "\e_${tmux}${location}${curdir}\e\\"   # pane_title
      else
        print -Pn "\ek${cmd}\e\\"                 # screen title
        print -Pn "\e_${curdir} ${location}\e\\"  # screen location
      fi
      ;;
    alacritty|xterm*)
      print -Pn "\e]0;${cmd} - ${location}${curdir}\a"
      ;;
  esac
}

function precmd() {
  title "-zsh"
}

function preexec() {
  # The full command line comes in as "$1"
  local cmd="$1"
  local -a args

  # add '--' in case $1 is only one word to work around a bug in ${(z)foo}
  # in zsh 4.3.9.
  tmpcmd="$1 --"
  args=(${(z)tmpcmd})

  # remove the '--' we added as a bug workaround..
  # per zsh manpages, removing an element means assigning ()
  # TODO: support fg %-
  args[${#args}]=()
  if [[ "${args[1]}" == "fg" ]] ; then
    local jobnum="${args[2]}"
    if [[ -z "$jobnum" ]] ; then
      # If no jobnum specified, find the current job.
      for i in ${(k)jobtexts}; do
        [[ -z "${jobstates[$i]%%*:+:*}" ]] && jobnum=$i
      done
    fi
    cmd="${jobtexts[${jobnum#%}]}"
  fi
  title "$cmd"
}

# randomizes order of stdin or given file
function rand() {
  RANDOM=$RANDOM`date +%s`        # seed
  while IFS= read -r in; do
    echo ${RANDOM}${RANDOM} "$in"
  done < ${1:-/dev/stdin} | sort -n | sed -e 's,^[0-9]* ,,'
}

function r() {
  . ~/.zshenv
  . ~/.zshrc
  fixagent
}

# rvm
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

# dircolors
if [[ -e ~/.dir_colors && -x =dircolors ]]; then
  eval $(dircolors ~/.dir_colors)
fi

fpath=("$HOME/.zsh/func" $fpath)
autoload add-zsh-hook

if [[ -e "/data" ]]; then
  DEVSHELL_EXTRA_MOUNTS="/data"
fi
DEVSHELL_IMAGE=fetep/devshell

for file in $HOME/.zsh/*.zsh(N); do
  . $file
done
