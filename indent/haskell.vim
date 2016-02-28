" indentation for haskell
"
" Based on idris indentation
"
" author: raichoo (raichoo@googlemail.com)
"
" Modify g:haskell_indent_if and g:haskell_indent_case to
" change indentation for `if'(default 3) and `case'(default 5).
" Example (in .vimrc):
" > let g:haskell_indent_if = 2

if exists('b:did_indent')
  finish
endif

let b:did_indent = 1

if !exists('g:haskell_indent_if')
  " if bool
  " >>>then ...
  " >>>else ...
  let g:haskell_indent_if = 3
endif

if !exists('g:haskell_indent_case')
  " case xs of
  " >>[]     -> ...
  " >>(y:ys) -> ...
  let g:haskell_indent_case = 2
endif

if !exists('g:haskell_indent_let')
  " let x = 0 in
  " >>>>x
  let g:haskell_indent_let = 4
endif

if !exists('g:haskell_indent_where')
  " where f :: Int -> Int
  " >>>>>>f x = x
  let g:haskell_indent_where = 6
endif

if !exists('g:haskell_indent_do')
  " do x <- a
  " >>>y <- b
  let g:haskell_indent_do = 3
endif

if !exists('g:haskell_indent_in')
  " let x = 1
  " >in x
  let g:haskell_indent_in = 1
endif

setlocal indentexpr=GetHaskellIndent()
setlocal indentkeys=0{,0},!^F,o,O,0\|,0\=,0=where,0=in,0=let,0=deriving,0=->,0=\=>

function! GetHaskellIndent()
  let l:prevline = getline(v:lnum - 1)

  if l:prevline =~ '^\s*$'
      return 0
  endif

  let l:line     = getline(v:lnum)

  if l:prevline =~ '^\s*--'
    return match(l:prevline, '\S')
  endif

  if l:line =~ '\C^\s*\<where\>'
    let l:s = match(l:prevline, '\S')
    return l:s + &shiftwidth
  endif

  if l:line =~ '\C^\s*\<deriving\>'
    let l:s = match(l:prevline, '\C\<\(newtype\|data\)\>')
    if l:s >= 0
      return l:s + &shiftwidth
    endif
  endif

  if l:line =~ '\C^\s*\<let\>'
    let l:s = match(l:prevline, '\C\<let\>')
    if l:s != 0
      return l:s
    endif
  endif

  if l:line =~ '\C^\s*\<in\>'
    let l:s = match(l:prevline, '\C\<let\>')
    if l:s >= 0
      return l:s + g:haskell_indent_in
    elseif match(l:prevline, '=') > 0
      let l:s = match(l:prevline, '\S')
      return l:s - (4 - g:haskell_indent_in)
    endif
  endif

  if l:line =~ '^\s*='
    if l:prevline =~ '\C^\<data\>\s\+[^=]\+\s*$'
        return match(l:prevline, '\C\<data\>') + &shiftwidth
    endif
  endif

  if l:line =~ '^\s*|'
    if l:prevline =~ '\C^\s*\<data\>\s\+[^=]\+\s\+=\s\+\S\+.*$'
      return match(l:prevline, '=')
    elseif match(l:prevline, '^\s*|\s') >= 0
        return match(l:prevline, '|')
    else
      return &shiftwidth
    endif
  endif

  if l:line =~ '^\s*[=-]>'
    let l:s = match(l:prevline, ' :: ')
    if l:s >= 0
      return l:s + 1
    endif
  endif

  if l:prevline =~ '\s\+[!#$%&*+./<>?@\\^|~-]\+\s*$'
    let l:s = match(l:prevline, '\S')
    if l:s > 0
      return l:s + &shiftwidth
    endif
  endif

  if l:prevline =~ '\C\<let\>\s\+[^=]\+=\s*$'
    return match(l:prevline, '\C\<let\>') + g:haskell_indent_let + &shiftwidth
  endif

  if l:prevline =~ '\C\<let\>\s\+.\+\(\<in\>\)\?\s*$'
    return match(l:prevline, '\C\<let\>') + g:haskell_indent_let
  endif

  if l:prevline !~ '\C\<else\>'
    let l:s = match(l:prevline, '\C\<if\>.*\&.*\zs\<then\>')
    if l:s > 0
      return l:s
    endif

    let l:s = match(l:prevline, '\C\<if\>')
    if l:s > 0
      return l:s + g:haskell_indent_if
    endif
  endif

  if l:prevline =~ '\C\(\<where\>\|\<do\>\|=\)\s*$'
    return match(l:prevline, '\S') + &shiftwidth
  endif

  if l:prevline =~ '\C\<where\>\s\+\S\+.*$'
    return match(l:prevline, '\C\<where\>') + g:haskell_indent_where
  endif

  if l:prevline =~ '\C\<do\>\s\+\S\+.*$'
    return match(l:prevline, '\C\<do\>') + g:haskell_indent_do
  endif

  if l:prevline =~ '\C\<case\>\s\+.\+\<of\>\s*$'
    return match(l:prevline, '\C\<case\>') + g:haskell_indent_case
  endif

  let l:hlstack = reverse(synstack(line('.'), col('.')))

  for l:hl in l:hlstack
    let l:synid = synIDattr(l:hl, 'name')

    if l:synid == 'haskellBlockComment'
        for l:c in range(v:lnum - 1, 0, -1)
            let l:bline = getline(l:c)
            if l:bline =~ '{-'
                return 1 + match(l:bline, '{-')
        endfor
        return 1
    endif

    if l:synid == 'haskellBlock'
      if l:line =~ '^\s*{'
        let l:s = match(l:prevline, '\S')
        if l:s >= 0
          return l:s + &shiftwidth
        endif
      endif

      return match(l:prevline, '{')
    endif

    if l:synid == 'haskellParens'
      return match(l:prevline, '(')
    endif

    if l:synid == 'haskellBrackets'
      return match(l:prevline, '[')
    endif
  endfor

  return match(l:prevline, '\S')
endfunction
