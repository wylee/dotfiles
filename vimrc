set nocompatible
filetype off

call pathogen#infect()

filetype plugin on

let mapleader = ","

" Use left and right arrow keys for buffer navigation
noremap  <Left>  <Esc>:bp<CR>
noremap  <Right> <Esc>:bn<CR>
inoremap <Left>  <C-o>:bp<CR>
inoremap <Right> <C-o>:bn<CR>

" Disable up and down arrow keys
noremap  <Up>    <NOP>
noremap  <Down>  <NOP>
inoremap <Up>    <NOP>
inoremap <Down>  <NOP>

" Move by screen line instead of text line.
" Relevant when text is wrapped.
nnoremap j gj
nnoremap k gk

" Convenient Esc
inoremap jj <ESC>

" Convenient save key for insert mode
inoremap <F2> <C-o>:w<CR>

" Copy to system clipboard
noremap <leader>y "+y
" Paste from system clipboard
noremap <leader>p "+p
noremap <leader>P "+P

" Basics
set encoding=utf-8
set cursorline
set mouse=a
set mousehide  " Hide pointer while typing
set ruler
set showmode
set showcmd
set showtabline=2
set wildmenu
set wildmode=list:longest

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
nnoremap <tab> %
vnoremap <tab> %

" Text formatting
set autoindent
set colorcolumn=+1
highlight ColorColumn ctermbg=7
set expandtab
set formatoptions=tcrqnl1
set list
set listchars=tab:»\ ,trail:·
set shiftwidth=4
set softtabstop=4
set textwidth=79

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

" Supertab
set ofu=syntaxcomplete#Complete
let g:SuperTabDefaultCompletionType = "context"

" Tagbar
let g:tagbar_usearrows = 1
nnoremap <leader>o :TagbarToggle<CR>

" Ack
nnoremap <leader>a :Ack<CR>

" \n to toggle NERDTree
noremap <silent> <leader>n :NERDTreeToggle<CR>

" Rope for Python
noremap <F3> :RopeGotoDefinition<CR>

