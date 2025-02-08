local dir

for dir in /opt/homebrew /home/linuxbrew/.linuxbrew; do
  if [[ -x "${dir}/bin/brew" ]]; then
    eval "$(${dir}/bin/brew shellenv)"
  fi

  if [[ -x "${dir}/bin/brew/bin/python3" ]]; then
    path+=($(${dir}/bin/brew/bin/python3 -m site --user-base)/bin)
  fi
done

unset dir
