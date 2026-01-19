# bracketed paste support, see https://cirw.in/blog/bracketed-paste

if [[ ${ZSH_VERSION:0:3} -ge 5.1 ]]; then
  set zle_bracketed_paste  # Explicitly restore this zsh default
  autoload -Uz bracketed-paste-magic
  zle -N bracketed-paste bracketed-paste-magic
fi
