# AGENTS.md - Agentic Coding Guide

This is a personal dotfiles repository. Configuration files are symlinked from
`home/` and `home-ws/` directories into `$HOME`.

## Repository Structure

```
dotfiles/
├── setup.sh          # Main setup script - creates symlinks
├── home/             # Dotfiles for all machines
│   ├── .zshrc, .zshenv, .gitconfig, .tmux.conf, etc.
│   ├── .zsh/         # Modular zsh configuration (*.zsh files)
│   ├── .config/nvim/ # Neovim configuration (Lua)
│   └── bin/          # Personal scripts
├── home-ws/          # Workstation-only dotfiles (if ~/.ws exists)
├── brew/             # Homebrew package management
│   ├── Brewfile      # Package list
│   └── Makefile      # brew bundle automation
└── backup/           # Backup of replaced files (auto-created)
```

## Commands

### Deploy Dotfiles
```bash
./setup.sh
```
- Symlinks files from `home/` to `$HOME`
- Also links `home-ws/` if hostname contains `fetep.net` or `~/.ws` exists
- Backs up existing files to `./backup/`
- Runs `make -C brew` if Homebrew is installed

### Homebrew Packages (macOS/Linux with Homebrew)
```bash
make -C brew              # Install/update packages from Brewfile
make -C brew Brewfile     # Regenerate Brewfile from installed packages
```

### No Formal Tests
This is a configuration repository. There is no test suite.
Verify changes by deploying and testing interactively.

## Languages & File Types

| Type | Files | Purpose |
|------|-------|---------|
| Bash/Zsh | `setup.sh`, `.zshrc`, `.zshenv`, `.zsh/*.zsh` | Shell config |
| Lua | `.config/nvim/**/*.lua` | Neovim configuration |
| Vimscript | `.vimrc` | Legacy Vim configuration |
| Config | `.tmux.conf`, `.gitconfig`, `.ripgreprc` | Tool configs |

## Code Style

### Shell Scripts (Bash/Zsh)

```bash
#!/usr/bin/env bash
set -euo pipefail  # Always use strict mode for scripts

# 2-space indentation
# Use [[ ]] over [ ] for conditionals
# Quote variables: "$variable" not $variable
# Use lowercase_snake_case for local variables
# Use UPPERCASE for exported environment variables

# Functions: descriptive names, no function keyword needed in zsh
my_function() {
  local var="value"
  # ...
}

# Prefer command substitution: $(cmd) over `cmd`
# Use heredocs for multi-line strings
```

**Key patterns from this repo**:
- `progname="${0##*/}"` - extract script name
- `cd "$(dirname "$0")"` - ensure correct working directory
- Check commands exist: `command -v foo >/dev/null` or `[[ -x =foo ]]`
- Use `local` for function-scoped variables
- Prefer `echo` for output, `>&2` for errors

### Lua (Neovim Configuration)

```lua
-- 4-space indentation
-- Single quotes for strings: 'string'
-- Trailing commas in tables
-- Comments above, not inline

-- Plugin spec format (lazy.nvim)
return {
    {
        'author/plugin-name',
        dependencies = {
            'dep1',
            'dep2',
        },
        config = function()
            -- setup code
        end,
    },
}
```

**Neovim-specific patterns**:
- Plugins go in `lua/fetep/plugins/*.lua` (one plugin per file)
- Each plugin file returns a table for lazy.nvim
- Use `vim.keymap.set()` for keymaps, not legacy `vim.api.nvim_set_keymap`
- Options via `vim.opt.X = value`
- Leader key is `,` (comma)

### Git Configuration

- Default branch: `master`
- Push behavior: `simple` with `autoSetupRemote = true`
- SSH preferred over HTTPS: `url "ssh://git@github.com/"` rewrites

### Indentation by File Type

| File Type | Indent | Tabs/Spaces |
|-----------|--------|-------------|
| Default | 2 | Spaces |
| Python | 4 | Spaces (PEP-8) |
| Bazel/Starlark | 4 | Spaces |
| Go | 2 | Tabs |
| Makefile | 2 | Tabs (required) |

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Shell variables | lowercase_snake_case | `local_agent`, `back_dir` |
| Environment vars | UPPERCASE | `SSH_AUTH_SOCK`, `EDITOR` |
| Shell functions | lowercase with underscores | `prompt_git_status()`, `fixagent()` |
| Lua functions | PascalCase for globals | `Toggle_diagnostic_virtual_text` |
| Lua locals | snake_case | `local cmp = require('cmp')` |
| Zsh modules | topic.zsh | `git.zsh`, `ssh.zsh` |

## Error Handling

### Shell
```bash
set -euo pipefail    # Exit on error, undefined vars, pipe failures
|| return 1          # Handle expected failures gracefully
>&2                  # Error messages to stderr
```

### Lua
```lua
-- Wrap in pcall for error-prone operations
local ok, result = pcall(function() ... end)

-- Check for nil before use
if vim.fn.exists('g:some_var') then ... end
```

## Important Notes

1. **No CI/CD** - Changes are tested manually by deploying
2. **Symlinks** - Files are symlinked, not copied. Edit in repo, not in $HOME
3. **Workstation detection** - `home-ws/` only deploys if `~/.ws` exists or hostname matches
4. **Homebrew optional** - brew setup only runs if `brew` command exists
5. **Backup safety** - Existing files are backed up before replacement
6. **Submodules** - `setup.sh` initializes git submodules automatically

## File Editing Guidelines

- Keep files focused and modular (see `~/.zsh/*.zsh` pattern)
- Add comments for non-obvious behavior
- Highlight trailing whitespace is enabled - don't leave any
- Use `textwidth=100` as a soft guide for line length
- Test changes by sourcing: `. ~/.zshrc` or `:source %` in vim/nvim

## Neovim Plugin Management

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim).

```bash
# After adding a plugin to lua/fetep/plugins/foo.lua:
nvim          # lazy.nvim auto-installs on startup
:Lazy         # Plugin management UI
:checkhealth  # Verify plugin health
```
