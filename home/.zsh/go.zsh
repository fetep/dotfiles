# path for newer Go versions
if [[ -d /usr/local/go ]]; then
  export GOROOT=/usr/local/go
  path=(/usr/local/go/bin "$path[@]")

  export GOPATH=$HOME/go
  mkdir -p $GOPATH/bin
  path+=($GOPATH/bin)
fi
