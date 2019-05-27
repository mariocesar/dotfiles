call plug#begin('~/.vim/plugged')

Plug 'ayu-theme/ayu-vim'
Plug 'morhetz/gruvbox'
Plug 'pangloss/vim-javascript', { 'for': ['javascript']}
Plug 'ctrlpvim/ctrlp.vim'
Plug 'Yggdroot/indentLine'
Plug 'airblade/vim-gitgutter'
Plug 'mattn/emmet-vim'
Plug 'gabrielelana/vim-markdown'
Plug 'vim-python/python-syntax'
Plug 'tpope/vim-surround'
Plug 'digitaltoad/vim-pug'
Plug 'alvan/vim-closetag'

call plug#end()

filetype plugin on
syntax on

" Defaults
let mapleader=","

if exists('g:GuiLoaded')
    GuiFont :h10
    GuiLinespace 0
endif

set number
set ruler
set encoding=utf-8
set termguicolors
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set splitbelow
set splitright
set mouse=a
set linespace=0
set autoindent smartindent
set smarttab
set laststatus=2

set clipboard+=unnamedplus
set inccommand=nosplit

set nobackup
set noswapfile

set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮,nbsp:·
set fillchars=diff:⣿,vert:│

set wildmenu
set wildignore=*.pyc
set wildignore+=*.o,*~,*.pyc,*/.git/*
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.tar.gz,*.min.*
set wildignore+=*.png,*.jpg,*.jpeg,*.svg,*.gif
set wildignore+=__pycache__/
set wildignore+=*/.idea/*
set wildignore+=*/.cache/*
set wildignore+=*/var/*
set wildignore+=*/venv/*
set wildignore+=*/.venv/*
set wildignore+=*/public/*
set wildignore+=*/node_modules/*
set wildignore+=*DS_Store*

"" Bindings {{

" 0 sends you the first char in the line, 1 send you the last
nnoremap 1 $

set pastetoggle=<F2>

vnoremap <Leader>s :sort<CR>

noremap <Leader>q :q<CR>
noremap <Leader>w :w<CR>

noremap <leader>c :tabnew<CR>
noremap <leader>q :tabclose<CR>
noremap <leader>j :tabprevious<CR>
noremap <leader>k :tabNext<CR>
noremap <leader>% :vsplit<CR>
noremap <leader>" :split<CR>

" Mantain the selected blocks when indenting
    vnoremap < <gv
    vnoremap > >gv
"" }}

"" Theming {{
set termguicolors
colorscheme ayu 

if has('gui_vimr') 
    let ayucolor="mirage"
    colorscheme ayu 
endif
" }}

let g:python_highlight_all = 1

" IndentLine {{
let g:indentLine_enabled = 1
let g:indentLine_char = '┆'
let g:indentLine_first_char = '┆'
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_setColors = 0
" }}

" Ctrl+P {{
let g:ctrlp_map = '<Leader>p'
let g:ctrlp_cmd = 'CtrlP'
" }}

" Emmet
let g:user_emmet_mode='a'

" Cleanup search highlight
vnoremap <c-S-d> y<ESC>/<c-r>"<CR>   
nnoremap <ESC><ESC> :let @/ = ""<CR>

" Strip trailing whitespaces on save {{
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd FileType html,css,sass,es6,jsx,js,python,markdown autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
" }}

" FileType Setup {{
autocmd FileType yaml set shiftwidth=2
autocmd FileType yaml set softtabstop=2
autocmd FileType yaml set tabstop=2
autocmd FileType yaml set textwidth=80
" }}

" Automatic toggling between line number modes
set number relativenumber

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" JSON syntax types {{
autocmd BufNewFile,BufRead,BufReadPost .babelrc set syntax=json
autocmd BufNewFile,BufRead,BufReadPost .eslintrc set syntax=json
autocmd BufNewFile,BufRead,BufReadPost .terserrc set syntax=json

" Show the quotes in JSON
autocmd Filetype json set conceallevel=0
" }}

" Django setup
augroup django
    autocmd!

    autocmd BufNewFile,BufRead *.html setlocal filetype=htmldjango
    autocmd FileType html,jinja,htmldjango setlocal foldmethod=manual

    autocmd FileType jinja,htmldjango nmap <buffer> <Leader>dt {%<space><space>%}<left><left><left>
    autocmd FileType jinja,htmldjango nmap <buffer> <Leader>df {{<space><space>}}<left><left><left>
augroup END

