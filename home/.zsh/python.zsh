export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT ]]; then
  path+=($PYENV_ROOT/bin)
fi
