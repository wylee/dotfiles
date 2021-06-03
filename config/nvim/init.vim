let mapleader = ","

syntax on

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

set mouse=a
set termguicolors

" Search
set gdefault
set hlsearch
set inccommand=nosplit
set incsearch
set showmatch
set smartcase
nnoremap <leader><space> :noh<cr>
