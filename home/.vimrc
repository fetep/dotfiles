set nocompatible

" https://github.com/tpope/vim-pathogen
execute pathogen#infect()

" solarized
syntax enable
set background=dark
set t_Co=256
colorscheme solarized

" general options
set incsearch
set smartcase
set ignorecase
set hlsearch
set showmode
set backspace=indent,eol,start
set textwidth=100

set ai
set ruler
set showmatch
set scrolloff=10  " guaranteed context lines

" style
set ts=2 sw=2 et
set shiftround
set listchars=tab:>-

filetype plugin indent on

function SetIndent(spaces, tabs=0)
  if a:tabs
    execute "set noet nolist"
  else
    execute "set et list"
  endif
  execute "set ts=" . a:spaces
  execute "set sts=" . a:spaces
  execute "set sw=" . a:spaces
endfunction

" default to 2-space indents with no tabs
call SetIndent(2, 0)

autocmd BufNewFile,BufRead Makefile call SetIndent(2, 1)
autocmd BufNewFile,BufRead *.go SetIndent(2, 1)
autocmd BufNewFile,BufRead *.jbuilder setlocal filetype=ruby
autocmd BufNewFile,BufRead *.py call SetIndent(4, 0) " PEP-8

" highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/

" mappings
let mapleader = ","
map <leader>2 :call SetIndent(2, 0)<CR>
map <leader>4 :call SetIndent(4, 0)<CR>
map <leader>m :noh<CR>
map <leader>n :noh<CR>
map <leader>p :set invpaste paste?<CR>
map <leader>t :call SetIndent(8, 1)<CR>
map <leader>t2 :call SetIndent(2, 1)<CR>
map <leader>t8 :call SetIndent(8, 1)<CR>

" reformat current paragraph
:nmap Q gqap

" reformat current selection
:vmap Q gq

" Set title string and push it to xterm/screen window title
set titlestring=vim\ %<%F%(\ %)%m%h%w%=%l/%L-%P
set titlelen=40
if &term == "screen-256color"
  set t_ts=k
  set t_fs=\
endif
if &term == "screen-256color" || &term == "xterm" || &term == "alacritty"
  set title
endif

" go
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_types = 1
let g:go_metalinter_autosave = 0
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
let g:go_fmt_command = "$GOROOT/bin/goimports"
"let g:go_gopls_enabled = 0

" terraform
let g:terraform_align=1
let g:terraform_fmt_on_save=1

" autoset :paste (bracketed paste)
" https://github.com/ConradIrwin/vim-bracketed-paste/blob/master/plugin/bracketed-paste.vim
let &t_ti .= "\<Esc>[?2004h"
let &t_te = "\e[?2004l" . &t_te

function! XTermPasteBegin(ret)
  set pastetoggle=<f29>
  set paste
  return a:ret
endfunction

execute "set <f28>=\<Esc>[200~"
execute "set <f29>=\<Esc>[201~"
map <expr> <f28> XTermPasteBegin("i")
imap <expr> <f28> XTermPasteBegin("")
vmap <expr> <f28> XTermPasteBegin("c")
cmap <f28> <nop>
cmap <f29> <nop>
