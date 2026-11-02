dotfiles
========

collection of my various dot files

## omp

Global omp preferences live in `home/.omp/agent/config.yml`. `./setup.sh` links this file to
`~/.omp/agent/config.yml`; databases, credentials, caches, and session history remain outside the repo.
`home/.omp/agent/AGENTS.md` symlinks to the same shared global rules as Pi
(`home/.config/opencode/AGENTS.md`), including Conventional Commit messages. omp loads these
automatically as native user context when a session starts.
omp uses Vim prompt editing, quiet startup, and direct text streaming, with diagnostics after edits.
Double-Escape has no extra action; ordinary Escape still handles Vim modes and interrupts.
The status bar shows the thinking level as text; word/emoji autocomplete and reaction emojis are off.
Default title icons are unchanged. The zsh title hook keeps omp's tmux window-name prefix short.
The extension in `home/.omp/agent/extensions/command-aliases.ts` aliases `/name` to `/rename`
and `/thinking` to `/effort`, preserving arguments. `thinking-cycle.ts` makes Shift-Tab alternate
between medium and high effort; other levels enter the cycle at medium on the next press.
Restart omp or run `/reload-plugins` after installing extension changes.

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
