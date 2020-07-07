call plug#begin('~/.local/share/nvim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'mattn/emmet-vim'
Plug 'morhetz/gruvbox'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'
Plug 'yggdroot/indentline'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'godlygeek/tabular'
Plug 'posva/vim-vue'
Plug 'vimwiki/vimwiki'
Plug 'reedes/vim-pencil'
Plug 'reedes/vim-textobj-sentence'

Plug 'vim-python/python-syntax'
Plug 'nvie/vim-flake8'

call plug#end()

filetype plugin on
syntax on

set termguicolors
set t_Co=256
colorscheme gruvbox

hi Normal guibg=NONE ctermbg=NONE

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
set autoindent
set smartindent
set laststatus=0
set conceallevel=0
set clipboard+=unnamedplus
set nowrap    " don't wrap lines
set nocursorline
set nocursorcolumn
set scrolljump=5
set autoread  " Detect when a file is changed
set nofoldenable
set list
set listchars=space:·,tab:→\ ,trail:·,extends:❯,precedes:❮,nbsp:·
set showbreak=↪
set showbreak=↪
set fillchars=diff:⣿,vert:│
set updatetime=100
set signcolumn=yes
set cmdheight=1
set lazyredraw     " Do not update the screen while a command/macro is running
set synmaxcol=800  " Don't try to lines highlight longer than 800 characters.
set shortmess=aITW " suppress PRESS ENTER messages by shortening messages
set hlsearch       " highlight matches
set ttimeout
set ttimeoutlen=100

set nobackup
set noswapfile
set noundofile
" set undofile
" set undolevels=1000
" set undoreload=10000

" Highlight trailing whitespace
highlight RedundantSpaces guifg=White guibg=DarkGray
match RedundantSpaces /\s\+$/

" Trim trailing spaces on save
function! StripTrailingWhitespaces()
    normal mZ
    " Strip trailing whitespaces
    silent execute ':%s/\s\+$//e'
    " Strip extra newlines from EOF
    silent execute ':%s/\n\+\%$//e'
    normal `Z
endfunction

autocmd BufWritePre *.vim,*.py,*.html,*.css,*.js,*.yml,*.ini,*.conf,Makefile :call StripTrailingWhitespaces()

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

let g:vimwiki_list = [{
   \'path': '~/Dropbox/Wiki/',
   \'syntax': 'markdown',
   \'ext': 'md'
\}]

map <Leader>w' <Plug>VimwikiSplitLink
map <Leader>w\ <Plug>VimwikiVSplitLink

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

" Fix for annoyances
nnoremap Q <Nop> " Disabling exmode enter

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

" Cleanup search highlight and redraw
noremap <silent> <ESC><ESC> :<C-u>nohlsearch<cr><C-l>
inoremap <silent> <ESC><ESC> <C-o>:nohlsearch<cr>

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

" Python setup
let g:python_highlight_all = 1
let g:flake8_show_in_gutter = 1
let g:flake8_quickfix_height = 3
let g:flake8_error_marker='❌'
let g:flake8_warning_marker='❗'
autocmd BufWritePost *.py call flake8#Flake8()

" Django setup
augroup django
    autocmd!

    autocmd BufNewFile,BufRead *.html setlocal filetype=htmldjango
    autocmd FileType html,jinja,htmldjango setlocal foldmethod=manual

    autocmd FileType jinja,htmldjango nmap <buffer> <Leader>dt {%<space><space>%}<left><left><left>
    autocmd FileType jinja,htmldjango nmap <buffer> <Leader>df {{<space><space>}}<left><left><left>
augroup END

augroup markdown
    autocmd!
    autocmd FileType markdown,mkd let g:pencil#textwidth=80
    autocmd FileType markdown,mkd setlocal colorcolumn=80
    autocmd FileType markdown,mkd call textobj#sentence#init()
                              \ | call pencil#init({'wrap': 'hard'})

augroup END
