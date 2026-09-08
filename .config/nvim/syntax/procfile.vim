" Procfile (foreman / honcho / overmind): <process-type>: <shell command>

if exists('b:current_syntax')
  finish
endif

syn case match

" Real shell highlighting for the command half.
syntax include @ProcfileShell syntax/sh.vim
" sh.vim sets this on the way out; leaving it would short-circuit the guard above.
unlet! b:current_syntax

syn keyword procfileTodo contained TODO FIXME XXX NOTE HACK
syn match procfileComment "^\s*\%(#\|//\).*$" contains=procfileTodo

syn match procfileEntry "^\s*[A-Za-z0-9_.-]\+\s*:" contains=procfileName,procfileColon
      \ nextgroup=procfileCommand skipwhite
syn match procfileName "[A-Za-z0-9_.-]\+" contained
syn match procfileColon ":" contained

syn match procfileCommand ".*$" contained
      \ contains=@ProcfileShell,procfileTrailComment,procfileHash
" Needs the leading blank so "http://" and "cmd#frag" stay part of the command.
syn match procfileTrailComment "\s\%(#\|//\).*$" contained contains=procfileTodo
" Claims a mid-word "#" before shComment can; sh.vim reads "url#frag" as a comment.
syn match procfileHash "\S\@<=#" contained

hi def link procfileComment      Comment
hi def link procfileTrailComment Comment
hi def link procfileTodo         Todo
hi def link procfileColon        Delimiter
hi def link procfileName         Function

let b:current_syntax = 'procfile'
