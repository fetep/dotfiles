set nocompatible
let mapleader = ","

" load vundle
" :PluginList, :PluginInstall, :PluginSearch foo, :PluginClean
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'fatih/vim-go'
Plugin 'hashivim/vim-terraform'
Plugin 'tpope/vim-fugitive' " git
Plugin 'VundleVim/Vundle.vim'
call vundle#end()
filetype plugin indent on
map <leader>V :PluginInstall<CR>

" solarized
syntax enable
set background=dark
set t_Co=256
"colorscheme solarized

" general options
set incsearch
set smartcase
set ignorecase
set hlsearch
set showmode
set backspace=indent,eol,start
set autowrite

set ai
set ruler
set showmatch
set scrolloff=10  " guaranteed context lines

" style
set ts=2 sw=2 et
set shiftround
set list
set listchars=tab:>-

autocmd BufNewFile,BufRead Makefile setlocal noet nolist ts=8 sw=8
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/

" mappings
map <leader>2 :set ts=2 sw=2<CR>
map <leader>4 :set ts=4 sw=4<CR>
map <leader>m :noh<CR>
map <leader>n :noh<CR>
map <leader>p :set invpaste paste?<CR>
map <leader>t :set noet ts=8 sw=8 nolist<CR>

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

" go
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_types = 1
let g:go_metalinter_autosave = 0
autocmd BufNewFile,BufRead *.go setlocal noet nolist ts=4 sw=4 textwidth=100
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
nnoremap <leader>a :cclose<CR>
autocmd FileType go nmap <leader>b  <Plug>(go-build)
autocmd FileType go nmap <leader>r  <Plug>(go-run)
let g:go_fmt_command = "$GO/bin/goimports"
"let g:go_gopls_enabled = 0

" terraform
let g:terraform_align=1
let g:terraform_fmt_on_save=1
