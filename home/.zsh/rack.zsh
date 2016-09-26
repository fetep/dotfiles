update-rack-vars() {
  local _dir

  unset _rack_dir
  for d in . .. ../.. ../../..; do
    _dir=${d:A} # zsh magic: convert relative to absolute path
    if [[ $_dir == $HOME ]]; then
      break
    fi

    if [[ -e "${_dir}/config.ru" ]]; then
      _rack_dir=$d
      break
    fi
  done

  if [[ -n "$_rack_dir" ]]; then
    : ${RACK_ENV:=development}
    export RACK_ENV
  else
    unset RACK_ENV
  fi
}

add-zsh-hook precmd update-rack-vars

re() {
  if [ -z "$_rack_dir" ]; then
    echo "re: not in a rack project" >&2
    return 1
  fi

  case $1 in
    prod)
      RACK_ENV="prod"
      ;;
    p*)
      RACK_ENV="production"
      ;;
    t*)
      RACK_ENV="test"
      ;;
    *)
      RACK_ENV="development"
  esac

  export RACK_ENV
  return 0
}
