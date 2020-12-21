let g:python3_host_prog = '/home/mariocesar/.pyenv/versions/neovim/bin/python3'
let g:python_host_prog = '/home/mariocesar/.pyenv/versions/neovim2/bin/python'

call plug#begin('~/.local/share/nvim/plugged')

" Navigation and browse
Plug 'ctrlpvim/ctrlp.vim'
Plug 'preservim/nerdtree'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Text formatting
Plug 'yggdroot/indentline'
Plug 'editorconfig/editorconfig-vim'

" Autocomplete
Plug 'mattn/emmet-vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'deoplete-plugins/deoplete-jedi'

" TODO: Use Intellisense automatic sync between vscode and read settings for
" .vscode folder
"Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}

" Theme and visuals
Plug 'morhetz/gruvbox'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'norcalli/nvim-colorizer.lua'

" Languages
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'posva/vim-vue'

" Productivity
Plug 'vimwiki/vimwiki'

" Python
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

set autoindent
set smartindent

set splitbelow
set splitright
set mouse=a
set linespace=0
set laststatus=1
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

set shortmess=A   " Ignore swap file
set shortmess+=I   " No splash message
set shortmess+=O   " file-read ovewrite previous
set shortmess+=T   " Truncate non-file message in middle
set shortmess+=W   " Don't echo WRITE when writing
set shortmess+=a   " Use abbreviation for file messages [RO] instead of [Read only]
set shortmess+=c   " Completition messages
set shortmess+=o   " file-write ovewrite previous
set shortmess+=t   " Truncate messages at the start

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

" Plug
let g:plug_window = 'botright new | resize 20'


" Status bar
let AirlineTheme = 'jellybeans'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" Javascript related
let g:vue_pre_processors = 'detect_on_enter'
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

" Autocomplete
let g:deoplete#enable_at_startup = 1

" Emmet
let g:user_emmet_install_global = 0
autocmd FileType html,htmldjango,css,jsx,js,vue EmmetInstall
let g:user_emmet_leader_key=','

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

" NerdTree

"" Open Nerdtree when a folder is specified
map <Leader>e :NERDTreeToggle<CR>

let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

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
