call plug#begin('~/.local/share/nvim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/emmet-vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'mattn/emmet-vim'
Plug 'morhetz/gruvbox'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'
Plug 'yggdroot/indentline'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'posva/vim-vue'

call plug#end()

filetype plugin on
syntax on

set termguicolors
set t_Co=256
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

set autoread  " Detect when a file is changed
set nocompatible
set nobackup
set noswapfile

set listchars=tab:→\ ,eol:¬,trail:•,extends:❯,precedes:❮,nbsp:·
set showbreak=↪
set fillchars=diff:⣿,vert:│

set updatetime=300
set shortmess+=c
set signcolumn=yes
set cmdheight=1
set lazyredraw " Do not update the screen while a command/macro is running
set title

" vim-vue
let g:vue_pre_processors = 'detect_on_enter'

" Javascript Libraries Syntax
let g:used_javascript_libs = 'jquery,underscore,react,vue'

" Ignore files
set wildmenu
set wildmode=longest,full

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

" Emmet
let g:user_emmet_install_global = 0
autocmd FileType html,htmldjango,css,jsx,js,vue EmmetInstall
"let g:user_emmet_leader_key = '<leader>e'
let g:user_emmet_leader_key = '<leader>,<CR>'

" Python Speedups
let g:python_host_skip_check=1
let g:python3_host_skip_check=1

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

" Set the working directory to the directory of the current file
noremap <leader>. :lcd %:p:h<CR>

" allow Tab and Shift+Tab to
" tab  selection in visual mode
vmap <Tab> >gv
vmap <S-Tab> <gv

" Neoclide/coc setup
let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-pairs',
  \ 'coc-tsserver',
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-json',
  \ ]

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

