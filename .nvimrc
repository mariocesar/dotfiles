let g:python3_host_prog = '/home/mariocesar/.pyenv/versions/3.6.4/bin/python'
let g:python_host_prog = '/home/mariocesar/.pyenv/versions/2.7.14/bin/python'

call plug#begin('~/.vim/plugged')

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

Plug 'NewProggie/NewProggie-Color-Scheme'
Plug 'ayu-theme/ayu-vim'
Plug 'pangloss/vim-javascript', { 'for': ['javascript']}
Plug 'flowtype/vim-flow', { 'for': ['javascript']}

Plug 'vim-syntastic/syntastic'
Plug 'Yggdroot/indentLine'
Plug 'airblade/vim-gitgutter'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-fugitive'

call plug#end()

let mapleader=","
let ayucolor="dark"

colorscheme ayu

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

set wildignore=*.pyc
set wildignore+=*.o,*~,*.pyc,*/.git/*
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.tar.gz,*.min.*
set wildignore+=*.png,*.jpg,*.jpeg,*.svg,*.gif
set wildignore+=*/__pycache__/*
set wildignore+=*/.idea/*
set wildignore+=*/.cache/*
set wildignore+=*/var/*
set wildignore+=*/public/*
set wildignore+=*/node_modules/*

let g:ctrlp_custom_ignore = '\v[\/]\.(node_modules|.cache|git|hg|svn)$'

" IndentLine {{
let g:indentLine_enabled = 1
let g:indentLine_char = '┆'
let g:indentLine_first_char = '┆'
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_setColors = 0
" }}

" Emmet
let g:user_emmet_mode='a'
let g:user_emmet_leader_key='<C-e>'

" Nerdtree
let NERDTreeIgnore = ['\.pyc$', '__pycache__', '\.cache', '\.git', '\.idea']

nmap <leader>o :!xdg-open "%"<cr>
nmap <F4> :NERDTreeToggle<CR>

vnoremap <c-S-d> y<ESC>/<c-r>"<CR>   
nnoremap <ESC><ESC> :let @/ = ""<CR>

fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd FileType html,css,sass,es6,jsx,js,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

let g:javascript_plugin_flow = 1
let g:syntastic_javascript_checkers = ['eslint']

let g:deoplete#enable_at_startup = 1

