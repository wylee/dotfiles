filetype plugin indent on
syntax on

let mapleader = ","

" Move by screen line instead of text line.
" Relevant when text is wrapped.
nnoremap j gj
nnoremap k gk

" Disable ex mode, which I have literally never used
nnoremap Q <nop>

" Disable command line history. This often pops up when trying to quit
" with :q but typing q: instead.
nnoremap q: <nop>

" Convenient insert mode save. The idea here is to press j and k at
" the same time without worrying about which of j or k is actually
" pressed first.
inoremap jk <ESC>:w<Enter>
inoremap kj <ESC>:w<Enter>

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
set termguicolors
set wildmenu
set wildmode=list:longest

" Search
nnoremap / /\v
vnoremap / /\v
set gdefault
set hlsearch
set inccommand=nosplit
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

augroup vimrc
    autocmd!

    autocmd FocusLost * :wa

    autocmd FileType css setlocal sw=2 sts=2
    autocmd FileType html setlocal sw=2 sts=2
    autocmd FileType javascript setlocal sw=2 sts=2
    autocmd FileType json setlocal sw=2 sts=2
    autocmd FileType markdown setlocal sw=2 sts=2 tw=72
    autocmd FileType text setlocal sw=2 sts=2 tw=72
    autocmd FileType yaml setlocal sw=2 sts=2 tw=79

    autocmd BufRead,BufNewFile ~/.bashrc.d/*.rc set filetype=sh

    " Python files:
    "     - Don't auto-wrap code
    "     - Make comments wrap at column 72 (works with format option c)
    "     - Display right margin in column 100
    autocmd FileType python setlocal fo-=t tw=72 cc=88
augroup END

function <SID>strip_trailing_whitespace()
    let l = line(".")
    let c = col(".")
    let s = @/
    %s/\s\+$//e
    call cursor(l, c)
    let @/ = s
endfun

noremap <leader>s :call <SID>strip_trailing_whitespace()<CR>
