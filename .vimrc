call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/emmet-vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'vim-python/python-syntax'

" Javascript
Plug 'pangloss/vim-javascript'
Plug 'maxmellon/vim-jsx-pretty'

" Colors
Plug 'altercation/vim-colors-solarized'
Plug 'Rigellute/rigel'
Plug 'sainnhe/edge'
Plug 'kyoto-shift/film-noir'
Plug 'yasukotelin/shirotelin'

call plug#end()

filetype plugin on
syntax on

" Defaults
let mapleader=","

if exists('g:GuiLoaded')
    GuiFont :h10
    GuiLinespace 0
endif

set hidden
set number
set ruler
set encoding=utf-8
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set splitbelow
set splitright
set mouse=a
set linespace=0
set autoindent smartindent
set complete-=i
set smarttab
set laststatus=2
set conceallevel=0
set cursorline

set clipboard+=unnamedplus

set nobackup
set noswapfile

set updatetime=300
set shortmess+=c
set signcolumn=yes
set cmdheight=2

set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮,nbsp:·
set fillchars=diff:⣿,vert:│

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

let g:ctrlp_custom_ignore = {
  \'dir':  '\v[\/](\.(git|hg|svn)|node_modules|\_site|public\/(media|static)|dist)',
  \'file': '\v\.(exe|so|dll|class|png|jpg|jpeg|log|tmp|swp|retry|gz|backup|dump)$',
\}

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
let g:solarized_termcolors=256
let g:solarized_contrast="high"
let g:solarized_hitrail=1 
let g:solarized_visibility="high"

set termguicolors
set background=dark
colorscheme solarized

let g:python_highlight_all = 1
"" }}

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
let g:user_emmet_leader_key=','

" A Cleanup search highlight
vnoremap <c-S-d> y<ESC>/<c-r>"<CR>   
nnoremap <ESC><ESC> :let @/ = ""<CR>

" Shortcuts command 
cmap Cd cd %:p:h

" Strip trailing whitespaces on save {{
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd FileType html,css,sass,es6,jsx,js,python,markdown autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
" }}

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


" Python
augroup python
    autocmd!
    autocmd FileType python
                \  syn keyword pythonSelf self
                \ | highlight def link pythonSelf Special
augroup end
