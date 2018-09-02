if has("syntax")
  syntax on
endif
set background=dark
set t_Co=256

set nocompatible
set incsearch
set smartcase
set ignorecase
set hlsearch
set showmode
set backspace=indent,eol,start

set ai
set ruler
set showmatch
set autowrite
set scrolloff=10  " guaranteed context lines

" style
set sts=2 sw=2 et
set shiftround
set list
set listchars=tab:>-

highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/

" file type settings
filetype plugin on
filetype on
autocmd BufNewFile,BufRead,BufEnter Capfile set ft=ruby
autocmd BufNewFile,BufRead,BufEnter *.json set ft=json

autocmd FileType make set noet sts=8 sw=8
autocmd FileType json set sts=3 sw=3

" mappings
map ,t :set noet sts=8 sw=8 nolist<CR>
map ,r :set syntax=ruby<CR>
map ,m :noh<CR>
map ,n :noh<CR>
map ,p :set invpaste paste?<CR>
map ,2 :set sts=2 sw=2<CR>
map ,4 :set sts=4 sw=4<CR>

" more intelligent function navigation
:map [[ :let @z=@/<CR>?{<CR>w99[{:let @/=@z<CR>
:map ][ :let @z=@/<CR>/}<CR>b99]}:let @/=@z<CR>
:map ]] :let @z=@/<CR>j0[[%/{<CR>:let @/=@z<CR>
:map [] :let @z=@/<CR>k$][%?}<CR>:let @/=@z<CR>

" reformat current paragraph
:nmap Q gqap

" reformat current selection
:vmap Q gq

" Set title string and push it to xterm/screen window title
set titlestring=vim\ %<%F%(\ %)%m%h%w%=%l/%L-%P
set titlelen=40
if &term == "screen" || &term == "screen-256color"
  set t_ts=k
  set t_fs=\
endif
if &term == "screen" || &term == "screen-256color" || &term == "xterm"
  set title
endif
