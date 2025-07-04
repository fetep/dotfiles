export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT ]]; then
  path+=($PYENV_ROOT/bin)
fi


export VIRTUAL_ENV_DISABLE_PROMPT=1
_setup_python_venv() {
  if [[ -d "venv" ]]; then
    if [[ "$PWD" != "$_python_venv" ]]; then
      source venv/bin/activate
      _python_venv="$PWD"
    fi
  else
    [[ -n "$_python_venv" ]] && deactivate
    unset _python_venv
  fi
}
add-zsh-hook chpwd _setup_python_venv
_setup_python_venv
