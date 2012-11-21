set nocompatible
filetype off

call pathogen#infect()
"set rtp+=~/.vim/bundle/vundle/
"call vundle#rc()
"Bundle 'gmarik/vundle'
"Bundle 'wincent/Command-T'
"Bundle 'scrooloose/nerdtree'
"Bundle 'scrooloose/nerdcommenter'
"Bundle 'tpope/vim-surround'
"Bundle 'git://repo.or.cz/vcscommand'
"Bundle 'kevinw/pyflakes-vim.git'
""Bundle 'klen/python-mode'

filetype plugin on

let mapleader = ","

" Disable arrow keys
nnoremap <Up>    <NOP>
nnoremap <Down>  <NOP>
nnoremap <Left>  <NOP>
nnoremap <Right> <NOP>
inoremap <Up>    <NOP>
inoremap <Down>  <NOP>
inoremap <Left>  <NOP>
inoremap <Right> <NOP>

" Move by screen line instead of text line.
" Relevant when text is wrapped.
nnoremap j gj
nnoremap k gk

" Convenient Esc
inoremap jj <ESC>

" Comment/uncomment lines
noremap <leader>/ :s/^/#/<CR>
noremap <leader>? :s/^#//<CR>

" \n to toggle NERDTree
map <leader>n :NERDTreeToggle<CR>

" Rope for Python
map <F3> :RopeGotoDefinition<CR>

" Basics
set encoding=utf-8
set cursorline
set ruler
set showmode
set showcmd
set showtabline=2
set wildmenu
set wildmode=list:longest

" Search
nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
nnoremap <leader><space> :noh<cr>
nnoremap <tab> %
vnoremap <tab> %

" Text formatting
set expandtab
set textwidth=79
set softtabstop=4
set shiftwidth=4
set autoindent
set formatoptions=tcrqnl1
set colorcolumn=+1
highlight ColorColumn ctermbg=7
set list
set listchars=tab:»\ ,trail:·

function <SID>strip_trailing_whitespace()
    let l = line(".")
    let c = col(".")
    let s = @/
    %s/\s\+$//e
    call cursor(l, c)
    let @/ = s
endfun

map <leader>s :call <SID>strip_trailing_whitespace()<CR>

augroup vimrc
    autocmd!

    autocmd FocusLost * :wa

    autocmd FileType css setlocal sw=2 sts=2
    autocmd FileType html setlocal sw=2 sts=2
    autocmd FileType javascript setlocal sw=2 sts=2
    autocmd FileType text setlocal sw=2 sts=2 tw=76

    autocmd BufRead,BufNewFile *.commit set filetype=commit
    autocmd FileType commit setlocal sw=2 sts=2 tw=72

    autocmd BufEnter *.mako set filetype=xml

    autocmd BufWritePre *.py :call <SID>strip_trailing_whitespace()
augroup END

set ofu=syntaxcomplete#Complete
let g:SuperTabDefaultCompletionType = "context"
