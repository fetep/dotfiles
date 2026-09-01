dotfiles
========

collection of my various dot files

## Private overlay

Set `DOTFILES_OVERLAY` to the path of a private repository using the same layout:

```
private-dotfiles/
├── home/       # all machines
└── home-ws/    # workstations only
```

Files in the private repository replace files at the same path here. Private-only files are also linked.
The `.zsh` and `.config/nvim` directories are merged so either repository can contribute files.

```bash
export DOTFILES_OVERLAY="$HOME/src/private-dotfiles"
./setup.sh
```

No overlay is applied when `DOTFILES_OVERLAY` is unset or empty.
