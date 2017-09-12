" setup pathogen

filetype off

call pathogen#infect()
call pathogen#helptags()

filetype plugin indent on
syntax on

set nocompatible
set history=1000
set autoindent
set autoread                                                 " reload files when changed on disk, i.e. via `git checkout`
set backspace=indent,eol,start
set backupcopy=yes                                           " see :help crontab
set clipboard=unnamed                                        " yank and paste with the system clipboard
set directory-=.                                             " don't store swapfiles in the current directory
set encoding=utf-8
set expandtab                                                " expand tabs to spaces
set ignorecase                                               " case-insensitive search
set incsearch                                                " search as you type
set laststatus=2                                             " always show statusline
set list                                                     " show trailing whitespace
set listchars=tab:▸\ ,trail:·,extends:❯,precedes:❮
set fillchars=diff:░,vert:│
set number                                                   " show line numbers
set numberwidth=1
set ruler                                                    " show where you are
set scrolloff=3                                              " show context above/below cursorline
set shiftwidth=4                                             " normal mode indentation commands use 2 spaces
set showcmd
set smartcase                                                " case-sensitive search if any caps
set softtabstop=4                                            " insert mode tab and backspace use 2 spaces
set tabstop=8                                                " actual tabs occupy 8 characters
set wildignore=*.pyc,*~
set wildmenu                                                 " show a navigable menu for tab completion
set wildmode=longest,list,full
set splitbelow
set splitright
set noswapfile
set nofoldenable

" Session related
set ssop-=options    " do not store global and local values in a session
set ssop-=folds      " do not store folds

" Resize splits when the window is resized
au VimResized * :wincmd =

" GVim options
if has("gui_running")
  set t_Co=256

  color codeschool

  set guioptions=aegit  " Hide menu bar and toolbar
  set guifont=Monospace\ 9
  set lines=50 columns=120
  set cursorline
endif

" search settings
set hlsearch
set ignorecase
set smartcase

nnoremap / /\v
vnoremap / /\v

" Time out on key codes but not mappings.
" Basically this makes terminal Vim work sanely.
set notimeout
set ttimeout
set ttimeoutlen=10

" key mappings
noremap  <F1> <nop>
inoremap <F1> <nop>
noremap <silent> <c-right> :tabnext<cr>
noremap <silent> <c-left> :tabprevious<cr>

" Nerdtree
noremap  <F3> :NERDTreeToggle<cr>
inoremap <F3> <esc>:NERDTreeToggle<cr>

set autochdir
let NERDTreeChDirMode=2

augroup ps_nerdtree
    au!

    au Filetype nerdtree setlocal nolist
    au Filetype nerdtree nnoremap <buffer> H :vertical resize -10<cr>
    au Filetype nerdtree nnoremap <buffer> L :vertical resize +10<cr>
augroup END

let NERDTreeHighlightCursorline = 1
let NERDTreeIgnore = ['.vim$', '\~$', '.*\.pyc$', 'pip-log\.txt$', 'whoosh_index',
                    \ 'xapian_index', '.*.pid', '.*-fixtures-.*.json',
                    \ '.*\.o$', 'db.db', 'tags.bak', '.*\.pdf$', '.*\.mid$',
                    \ '.idea', '.settings',
                    \ '.*\.midi$', '\.egg-info$']

let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let NERDChristmasTree = 1
let NERDTreeChDirMode = 2
let NERDTreeMapJumpFirstChild = 'gK'

" Emmet
let g:user_emmet_leader_key = '<c-space>'

let g:user_emmet_settings = {
            \  'html' : {
            \    'indentation' : '  ',
            \    'snippets': {
            \        'block'   : "{% block ${cursor} %}\n${cursor}${child}\n{% endblock %}",
            \        'url'     : "{% url '${cursor}' %}",
            \        'static'  : "{% static '${cursor}' %}",
            \        'load'    : "{% load ${cursor} %}",
            \        'extends' : "{% extends '${cursor}' %}",
            \        'csrf'    : "{% csrf_token %}",
            \        'for'     : "{% for ${cursor} in ${cursor} %}\n${cursor}${child}\n{% endfor %}",
            \        'trans'   : "{% trans '${cursor}' %}",
            \        'blocktrans' : "{% blocktrans %}${cursor}{% endblocktrans %}",
            \    },
            \  },
            \}


" Python mode

let g:pymode_rope_goto_definition_bind = "<C-]>"
let g:pymode_run_bind = "<C-S-e>"
let g:pymode_doc_bind = "<C-S-d>"

"" From: http://bling.github.io/blog/2013/07/21/smart-tab-expansions-in-vim-with-expression-mappings/
function! s:zen_html_tab()
  return "\<c-space>,"
endfunction

autocmd FileType html imap <buffer><expr><c-tab> <sid>zen_html_tab()

" Python
augroup ft_python
    au!

    " Turn on omnicompletion
    set ofu=syntaxcomplete#Complete
    set completeopt=longest,menuone

    " Continue omnicompletion for python modules
    "imap <silent> <buffer> . .<C-X><C-O>

    " Pylint relates
    let g:pymode_lint = 1
    let g:pymode_lint_onfly = 1
    let g:pymode_lint_write = 1
    let g:pymode_lint_cwindow = 0
    let g:pymode_python = 'python3'
    let g:pymode_virtualenv = 1

augroup END

" Django
augroup ft_django
    au!

    au BufNewFile,BufRead urls.py           setlocal nowrap
    au BufNewFile,BufRead urls.py           normal! zR
    au BufNewFile,BufRead dashboard.py      normal! zR
    au BufNewFile,BufRead local_settings.py normal! zR

    au BufNewFile,BufRead admin.py     setlocal filetype=python.django
    au BufNewFile,BufRead urls.py      setlocal filetype=python.django
    au BufNewFile,BufRead models.py    setlocal filetype=python.django
    au BufNewFile,BufRead views.py     setlocal filetype=python.django
    au BufNewFile,BufRead forms.py     setlocal filetype=python.django
augroup END

" Session related
set ssop-=options    " do not store global and local values in a session
set ssop-=folds      " do not store folds

let g:session_autosave = 'no'
