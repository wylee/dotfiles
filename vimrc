set nocompatible
filetype off

silent! call pathogen#infect()
silent! call pathogen#helptags()

filetype plugin indent on

let mapleader = ","

syntax on

" Use arrow keys for window navigation
noremap <Left>  <C-w>h
noremap <Down>  <C-w>j
noremap <Up>    <C-w>k
noremap <Right> <C-w>l

" Disable up and down arrow keys and some other insert mode navigation
inoremap <Left>  <NOP>
inoremap <Down>  <NOP>
inoremap <Up>    <NOP>
inoremap <Right> <NOP>
inoremap <Home>  <NOP>
inoremap <End>   <NOP>

" Move by screen line instead of text line.
" Relevant when text is wrapped.
nnoremap j gj
nnoremap k gk

" Convenient Esc
inoremap jj <ESC>

" Copy to system clipboard
noremap <leader>y "+y
" Paste from system clipboard
noremap <leader>p "+p
noremap <leader>P "+P

" Basics
set shell=/bin/bash
set autowrite
set backspace=indent,eol,start
" Fixes 'crontab: temp file must be edited in place' on Mac OS
set backupskip+=/private/tmp/*
set cursorline
set encoding=utf-8
set foldlevel=99
set foldmethod=indent
set hidden
set mouse=a
set mousehide  " Hide pointer while typing
set ruler
set showcmd
set showmode
set showtabline=1
set wildmenu
set wildmode=list:longest

" GUI
" Hide toolbar
set guioptions-=T
" Hide scrollbars
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L
set guioptions-=b

" Search
nnoremap / /\v
vnoremap / /\v
set gdefault
set hlsearch
set ignorecase
set incsearch
set showmatch
set smartcase
nnoremap <leader><space> :noh<cr>

" Text formatting
set autoindent
if exists('&colorcolumn')
    set colorcolumn=+1
endif
highlight ColorColumn ctermbg=7
set expandtab
set formatoptions=tcrqnl1
if v:version >= 703
    set formatoptions+=j
endif
set list
set listchars=tab:»\ ,trail:·
set shiftwidth=4
set softtabstop=4
set textwidth=99

function <SID>strip_trailing_whitespace()
    let l = line(".")
    let c = col(".")
    let s = @/
    %s/\s\+$//e
    call cursor(l, c)
    let @/ = s
endfun

noremap <leader>s :call <SID>strip_trailing_whitespace()<CR>

augroup vimrc
    autocmd!
    autocmd BufWritePost <buffer> silent redraw

    autocmd FocusLost * :wa

    autocmd FileType css setlocal sw=4 sts=4
    autocmd FileType html setlocal sw=4 sts=4
    autocmd FileType javascript setlocal sw=4 sts=4
    autocmd FileType markdown setlocal sw=2 sts=2 tw=72
    autocmd FileType text setlocal sw=2 sts=2 tw=72

    autocmd BufRead,BufNewFile *.mako set filetype=mako
    autocmd FileType mako setlocal sw=2 sts=2

    autocmd BufRead,BufNewFile *.commit set filetype=gitcommit
    autocmd FileType gitcommit setlocal sw=4 sts=4 tw=72

    autocmd BufRead,BufNewFile ~/.bashrc.d/*.rc set filetype=sh

    " Python files:
    "     - Don't auto-wrap code
    "     - Make comments wrap at column 72 (works with format option c)
    "     - Display right margin in column 100
    autocmd FileType python setlocal fo-=t tw=72 cc=100

    " Set default completion function only if one isn't already set on the
    " file.
    autocmd FileType *
                \ if &omnifunc == "" |
                \     setlocal omnifunc=syntaxcomplete#Complete |
                \ endif

    autocmd BufRead,BufNewFile CHANGELOG set filetype=rst
augroup END

" Supertab
let g:SuperTabDefaultCompletionType = "context"

" NERDCommenter
" Make comment toggling easier
nmap <silent> <leader>/ <leader>c<space>
xmap <silent> <leader>/ <leader>c<space>
