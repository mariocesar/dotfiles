let g:python3_host_prog = '/home/mariocesar/.pyenv/versions/3.6.4/bin/python'
let g:python_host_prog = '/home/mariocesar/.pyenv/versions/2.7.14/bin/python'

call plug#begin('~/.vim/plugged')

Plug 'NewProggie/NewProggie-Color-Scheme'
Plug 'ayu-theme/ayu-vim'
Plug 'morhetz/gruvbox'

Plug 'roxma/nvim-completion-manager'
Plug 'pangloss/vim-javascript', { 'for': ['javascript']}

Plug 'ctrlpvim/ctrlp.vim'

Plug 'Yggdroot/indentLine'
Plug 'airblade/vim-gitgutter'
Plug 'mattn/emmet-vim'
Plug 'gabrielelana/vim-markdown'

call plug#end()

" Defaults
let mapleader=","

colorscheme gruvbox 
set background=dark

let g:gruvbox_contrast_dark="hard"
let g:gruvbox_improved_strings=0
let g:gruvbox_improved_warnings=1

if exists('g:GuiLoaded')
    GuiFont :h10
    GuiLinespace 0
endif

colorscheme gruvbox 
set background=dark

let g:gruvbox_contrast_dark="hard"
let g:gruvbox_improved_strings=0
let g:gruvbox_improved_warnings=1

let mapleader=","
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

set wrapmargin=2
set formatoptions-=t
set formatoptions+=a

set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮,nbsp:·
set fillchars=diff:⣿,vert:│

set wildmenu
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

" Key maps {{
nnoremap 1 $
" }}

" Theming {{
set termguicolors
colorscheme ayu 

if has('gui_vimr') 
    let ayucolor='light'
    colorscheme ayu 
    autocmd ColorScheme * hi! Normal guibg=white ctermbg=white
endif
" }}

" Plasticboy Markdown 
set conceallevel=2
let g:markdown_enable_conceal = 1
let g:vim_markdown_folding_disabled = 0
let g:markdown_enable_spell_checking = 0

" IndentLine {{
let g:indentLine_enabled = 1
let g:indentLine_char = '┆'
let g:indentLine_first_char = '┆'
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_setColors = 0
" }}

" Ctrl+P {{
let g:ctrlp_map = '<c-p>'
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

