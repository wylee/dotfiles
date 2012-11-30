set nocompatible
filetype off

call pathogen#infect()

filetype plugin indent on

let mapleader = ","

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

" Convenient save key for insert mode
inoremap <F2> <C-o>:w<CR>

" Copy to system clipboard
noremap <leader>y "+y
" Paste from system clipboard
noremap <leader>p "+p
noremap <leader>P "+P

" Basics
set autowrite
set cursorline
highlight CursorLine cterm=NONE ctermbg=7
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
set colorcolumn=+1
highlight ColorColumn ctermbg=7
set expandtab
set formatoptions=tcrqnl1
set list
set listchars=tab:»\ ,trail:·
set shiftwidth=4
set smartindent
set smarttab
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

    autocmd BufRead,BufNewFile *.mako set filetype=mako
    autocmd FileType mako setlocal sw=2 sts=2

    autocmd BufRead,BufNewFile *.commit set filetype=commit
    autocmd FileType commit setlocal sw=2 sts=2 tw=72

    autocmd BufWritePre *.py :call <SID>strip_trailing_whitespace()
augroup END

" Supertab
set ofu=syntaxcomplete#Complete
let g:SuperTabDefaultCompletionType = "context"

" Tagbar
let g:tagbar_usearrows=1
let g:tagbar_left=1
nnoremap <leader>tb :TagbarToggle<CR>

" Ack search; ! keeps Ack from opening the first match automatically
nnoremap <leader>a :Ack!<space>

" NERDCommenter
" Make comment toggling easier
nmap <silent> <leader>/ <leader>c<space>
xmap <silent> <leader>/ <leader>c<space>

" \n to toggle NERDTree
noremap <silent> <leader>n :NERDTreeToggle<CR>

" Rope for Python
noremap <F3> :RopeGotoDefinition<CR>

" CtrlP 'o' is for open
silent! nnoremap <unique> <silent> <leader>o :CtrlP<CR>

" BufExplorer
noremap <script> <silent> <unique> <leader>b :BufExplorer<CR>

" Gundo
let g:gundo_right=1
nnoremap <F5> :GundoToggle<CR>
