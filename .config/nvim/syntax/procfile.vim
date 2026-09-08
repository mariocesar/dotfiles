" Procfile (foreman / honcho / overmind): <process-type>: <shell command>

if exists('b:current_syntax')
  finish
endif

syn case match

syn keyword procfileTodo contained TODO FIXME XXX NOTE HACK
syn match procfileComment "^\s*\%(#\|//\).*$" contains=procfileTodo

syn match procfileEntry "^\s*[A-Za-z0-9_.-]\+\s*:" contains=procfileName,procfileColon
      \ nextgroup=procfileCommand skipwhite
syn match procfileName "[A-Za-z0-9_.-]\+" contained
syn match procfileColon ":" contained

syn match procfileCommand ".*$" contained
      \ contains=procfileVariable,procfileString,procfileRawString,procfileOperator,procfileTrailComment
" Needs the leading blank so "http://" and "cmd#frag" stay part of the command.
syn match procfileTrailComment "\s\%(#\|//\).*$" contained contains=procfileTodo
syn match procfileVariable "\$\%(\h\w*\|{[^}]*}\|[@*#?$!0-9-]\)" contained
syn match procfileOperator "&&\|||\|[|&;<>]" contained
syn region procfileString start=+"+ skip=+\\"+ end=+"+ contained contains=procfileVariable
syn region procfileRawString start=+'+ end=+'+ contained

hi def link procfileComment      Comment
hi def link procfileTrailComment Comment
hi def link procfileTodo         Todo
hi def link procfileColon        Delimiter
hi def link procfileOperator     Operator
hi def link procfileVariable     Identifier
hi def link procfileString       String
hi def link procfileRawString    String
hi def link procfileName         Function

" One color per process type, assigned in order of appearance, wrapping at 8.
let s:palette = [
      \ ['#e06c75', 204], ['#98c379', 114], ['#61afef',  75], ['#e5c07b', 180],
      \ ['#c678dd', 176], ['#56b6c2',  73], ['#d19a66', 173], ['#f78ca7', 211],
      \ ]

function! s:Highlights() abort
  let l:i = 0
  for [l:gui, l:cterm] in s:palette
    execute printf('highlight default procfileName%d cterm=bold gui=bold ctermfg=%d guifg=%s',
          \ l:i, l:cterm, l:gui)
    let l:i += 1
  endfor
endfunction

function! s:Colorize() abort
  for l:i in range(get(b:, 'procfile_name_count', 0))
    execute 'silent! syntax clear procfileNameOf' . l:i
  endfor

  let l:names = []
  for l:line in getline(1, '$')
    let l:name = matchstr(l:line, '^\s*\zs[A-Za-z0-9_.-]\+\ze\s*:')
    if !empty(l:name) && index(l:names, l:name) < 0
      call add(l:names, l:name)
    endif
  endfor

  let l:i = 0
  for l:name in l:names
    " Defined after procfileName, so it wins at the same start position.
    execute printf('syntax match procfileNameOf%d "[A-Za-z0-9_.-]\@<!%s\ze\s*:" contained containedin=procfileEntry',
          \ l:i, escape(l:name, '.*$^~[]\/"'))
    execute printf('highlight! default link procfileNameOf%d procfileName%d', l:i, l:i % len(s:palette))
    let l:i += 1
  endfor
  let b:procfile_name_count = len(l:names)
endfunction

call s:Highlights()
call s:Colorize()

augroup procfile_syntax
  autocmd! * <buffer>
  autocmd BufWritePost,InsertLeave <buffer> call s:Colorize()
augroup END

augroup procfile_colors
  autocmd!
  autocmd ColorScheme * call s:Highlights()
augroup END

let b:current_syntax = 'procfile'
