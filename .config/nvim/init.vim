set nocompatible
filetype off

let g:python3_host_prog = '/home/mariocesar/.pyenv/versions/neovim/bin/python3'
let g:python_host_prog = '/home/mariocesar/.pyenv/versions/neovim2/bin/python'

call plug#begin('~/.local/share/nvim/plugged')

    " Navigation and browse
    Plug 'ctrlpvim/ctrlp.vim'

    " Text formatting
    Plug 'yggdroot/indentline'
    Plug 'editorconfig/editorconfig-vim'

    " Autocomplete
    Plug 'mattn/emmet-vim'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    " Theme and visuals
    Plug 'morhetz/gruvbox'
    Plug 'airblade/vim-gitgutter'
    Plug 'itchyny/lightline.vim'
    Plug 'norcalli/nvim-colorizer.lua'

    " Languages
    Plug 'othree/javascript-libraries-syntax.vim'
    Plug 'posva/vim-vue'
    Plug 'tpope/vim-ragtag' " Endings for xml languages
    Plug 'othree/html5.vim', { 'for': 'html' }

    " Productivity
    Plug 'vim-ctrlspace/vim-ctrlspace'
    Plug 'vimwiki/vimwiki'
    Plug 'vifm/vifm.vim'

    " Python
    Plug 'vim-python/python-syntax'
    Plug 'nvie/vim-flake8', { 'for': 'python' }

    " Syntax
    Plug 'chr4/nginx.vim'
call plug#end()

filetype plugin indent on
syntax on

set termguicolors
set t_Co=256

if &term =~ '256color'
    " disable background color erase
    set t_ut=
endif

" enable 24 bit color support if supported
if (has("termguicolors"))
    if (!(has("nvim")))
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    endif
    set termguicolors
endif


colorscheme gruvbox

hi Normal guibg=NONE ctermbg=NONE

let mapleader=","

set hidden
set ruler
set encoding=utf-8

" Tabs vs spaces
set expandtab
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set shiftround " round indent to a multiple of 'shiftwidth'

set autoindent
set smartindent

set splitbelow
set splitright
set mouse=a
set linespace=0
set conceallevel=0
set backspace=indent,eol,start " make backspace behave in a sane manner
set clipboard+=unnamedplus
set nowrap    " don't wrap lines
set nocursorline
set nocursorcolumn
set scrolljump=5
set scrolloff=8
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

set laststatus=2
set title          " Vim sets terminal title

set shortmess=A    " Ignore swap file
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

set exrc " Enable the loading of local .vimrc config files in the current directory

" Highlight trailing whitespace
highlight RedundantSpaces guifg=White guibg=DarkGray
match RedundantSpaces /\s\+$/

" Make comments italic
highlight Comment cterm=italic term=italic gui=italic

" GitGutter
let g:gitgutter_realtime = 1
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '±'
let g:gitgutter_sign_removed = '⨯'
let g:gitgutter_sign_removed_first_line = '⨯'
let g:gitgutter_sign_modified_removed = '±'
let g:gitgutter_highlight_nr_lines = 1

autocmd BufEnter * GitGutterLineNrHighlightsEnable

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
let g:lightline = {
  \ 'colorscheme': 'wombat',
\ }

" Javascript related
let g:vue_pre_processors = 'detect_on_enter'
let g:used_javascript_libs = 'jquery,underscore,react,vue'

" Autocomplete COC

let g:coc_global_extensions = [
\ 'coc-css',
\ 'coc-json',
\ 'coc-tsserver',
\ 'coc-git',
\ 'coc-eslint',
\ 'coc-tslint-plugin',
\ 'coc-pairs',
\ 'coc-sh',
\ 'coc-vimlsp',
\ 'coc-emmet',
\ 'coc-prettier',
\ 'coc-ultisnips',
\ 'coc-explorer',
\ 'coc-diagnostic'
\ ]

if exists("*CocActionAsync")
    autocmd CursorHold * silent call CocActionAsync('highlight')
endif

" coc-prettier
command! -nargs=0 Prettier :CocCommand prettier.formatFile
nmap <leader>f :CocCommand prettier.formatFile<cr>

" Manage files
set path+=**    " Searches current directory recursively
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

let g:netrw_liststyle = 3
let g:netrw_banner = 0
let g:netrw_winsize = 25
let g:netrw_list_hide = '__pycache__,\.git,egg\-info'

let g:vimwiki_list = [{
   \'path': '~/Dropbox/Wiki/',
   \'syntax': 'markdown',
   \'ext': 'md'
\}]

map <Leader>w' <Plug>VimwikiSplitLink
map <Leader>w\ <Plug>VimwikiVSplitLink

" Autocomplete
let g:deoplete#enable_at_startup = 1


let g:CtrlSpaceDefaultMappingKey = "<Leader><space> "

" Emmet
let g:user_emmet_install_global = 0
autocmd FileType html,htmldjango,css,jsx,js,vue EmmetInstall
let g:user_emmet_leader_key=','

" Ctrl+P options

let g:ctrlp_custom_ignore = {
  \'dir':  '\v[\/](\.(git|hg|svn)|node_modules|\_site|public\/(media|static)|dist)',
  \'file': '\v\.(exe|so|dll|class|png|jpg|jpeg|log|tmp|swp|retry|gz|backup|dump)$',
\}

let g:ctrlp_map = '<Leader>p'
let g:ctrlp_cmd = 'CtrlP'

map <Leader>vv :Vifm<CR>
map <Leader>vs :VsplitVifm<CR>
map <Leader>vt :TabVifm<CR>

map <Leader>tt :new term://zsh<CR>     " Open terminal

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
let g:python_host_skip_check=1
let g:python3_host_skip_check=1

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
