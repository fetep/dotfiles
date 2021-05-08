# path for newer Go versions
if [[ -d /usr/local/go ]]; then
  path=(/usr/local/go/bin "$path[@]")
fi

if [[ -d ~/go ]]; then
  export GOPATH=$HOME/go
  path+=($GOPATH/bin)
fi
