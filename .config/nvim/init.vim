call plug#begin('~/.local/share/nvim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/emmet-vim'
Plug 'editorconfig/editorconfig-vim'
"Plug 'vim-syntastic/syntastic'
Plug 'morhetz/gruvbox'

call plug#end()

filetype plugin on
syntax on

colorscheme gruvbox

let mapleader=","

set hidden
set ruler
set encoding=utf-8
set expandtab
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set splitbelow
set splitright
set mouse=a
set linespace=0
set autoindent smartindent
set laststatus=2
set conceallevel=0
set clipboard+=unnamedplus

set nocursorline
set nocursorcolumn
set scrolljump=5

set nocompatible
set nobackup
set noswapfile

set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮,nbsp:·
set fillchars=diff:⣿,vert:│

set updatetime=300
set shortmess+=c
set signcolumn=yes
set cmdheight=1

" Ignore files
set wildmenu

set wildignore=*.o,*~,*.pyc
set wildignore+=*/.git/**
set wildignore+=*/tmp/**,*.so,*.swp,*.zip,*.tar.gz,*.min.*
set wildignore+=*.png,*.jpg,*.jpeg,*.svg,*.gif
set wildignore+=*/__pycache__/
set wildignore+=*/.idea/**
set wildignore+=*/.cache/**
set wildignore+=*/var/**
set wildignore+=*/venv/**
set wildignore+=*/.venv/**
set wildignore+=*/public/media/**
set wildignore+=*/public/static/**
set wildignore+=*/node_modules/**
set wildignore+=*DS_Store*

" Python Speedups
let g:python_host_skip_check=1
let g:python_host_prog = '/usr/local/bin/python2'
let g:python3_host_skip_check=1
let g:python3_host_prog = '/usr/local/bin/python3'

" Ctrl+P options
let g:ctrlp_custom_ignore = {
  \'dir':  '\v[\/](\.(git|hg|svn)|node_modules|\_site|public\/(media|static)|dist)',
  \'file': '\v\.(exe|so|dll|class|png|jpg|jpeg|log|tmp|swp|retry|gz|backup|dump)$',
\}

let g:ctrlp_map = '<Leader>p'
let g:ctrlp_cmd = 'CtrlP'

" Shortcuts
vnoremap <Leader>s :sort<CR>

noremap <Leader>q :q<CR>
noremap <Leader>w :w<CR>

noremap <leader>c :tabnew<CR>
noremap <leader>q :tabclose<CR>
noremap <leader>j :tabprevious<CR>
noremap <leader>k :tabNext<CR>
noremap <leader>% :vsplit<CR>
noremap <leader>" :split<CR>

" Cleanup search highlight
vnoremap <c-S-d> y<ESC>/<c-r>"<CR>
nnoremap <ESC><ESC> :let @/ = ""<CR>

" Mantain the selected blocks when indenting
vnoremap < <gv
vnoremap > >gv

" Yaml
augroup yaml
    autocmd!
    autocmd FileType yaml set shiftwidth=2
    autocmd FileType yaml set softtabstop=2
    autocmd FileType yaml set tabstop=2
    autocmd FileType yaml set textwidth=80
augroup END

" Automatic toggling between line number modes
set number relativenumber

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" JSON syntax types
augroup json
    autocmd!
    autocmd BufEnter * set conceallevel=0
    autocmd BufNewFile,BufRead,BufReadPost .babelrc set syntax=json
    autocmd BufNewFile,BufRead,BufReadPost .eslintrc set syntax=json
    autocmd BufNewFile,BufRead,BufReadPost .terserrc set syntax=json
augroup END

" Django setup
augroup django
    autocmd!

    autocmd BufNewFile,BufRead *.html setlocal filetype=htmldjango
    autocmd FileType html,jinja,htmldjango setlocal foldmethod=manual

    autocmd FileType jinja,htmldjango nmap <buffer> <Leader>dt {%<space><space>%}<left><left><left>
    autocmd FileType jinja,htmldjango nmap <buffer> <Leader>df {{<space><space>}}<left><left><left>
augroup END

