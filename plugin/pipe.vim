" Plugin: Pipe
" Author: Nguyen Nguyen <NLKNguyen@MSN.com>
" License: MIT
" Origin: http://github.com/NLKNguyen/pipe.vim

" Main: {{{
let s:Pipe_Command_Prefix = ':!'
let s:Pipe_Command_Postfix = ''
fun! g:Pipe(cmd)
    echohl String | echon 'Pipe running... (press ctrl-c to abort)' | echohl None

    silent! exe "noautocmd botright pedit ¦"
    noautocmd wincmd P
    setlocal modifiable
    normal ggdG

    call s:Load_Pipe_Preview_Settings()

    set buftype=nofile
    " silent! exe "noautocmd .! echo '" . escape(a:cmd, '%#\') . "'"
    silent! exe "noautocmd .! " . escape(a:cmd, '%#\')
    normal G
    setlocal nomodifiable
    noautocmd wincmd p
    echohl Comment | echon 'Pipe finished at ' . strftime("%H:%M:%S ") | echohl None
endfun

command! -nargs=1 -bang -complete=shellcmd  Pipe :call g:Pipe(<f-args>)
" }}}


" Preview Window Settings: {{{
" Default settings (can be set by users)
let g:Pipe_Preview_LineNr = 0
let g:Pipe_Preview_Wrap   = 0

" @brief Load default or user settings
fun! s:Load_Pipe_Preview_Settings()
    if exists("g:Pipe_Preview_Wrap")
      if g:Pipe_Preview_Wrap ==? '0'
        setlocal nowrap
      else
        setlocal wrap
      endif
    endif

    if exists("g:Pipe_Preview_LineNr")
      if g:Pipe_Preview_LineNr ==? '0'
        setlocal nonumber
      else
        setlocal number
      endif
    endif
endfun
"}}}


" Get Or Set Variables: {{{
fun! g:PipeGetVar(varname, prompt, visibility)
  " TODO
  echo 'test2'
endfun


fun! g:PipeSetVar(varname, prompt, visibility)
  " TODO
endfun
" }}}

function! g:PipeGet(varname, prompt)
  " let l:prefix = "b:PipeMongoDB_LOCAL_VAR_"
  " let l:variable = l:prefix . a:varname
  " if !exists(l:variable)
  "   let {l:variable} = input(a:prompt . " = ")

  " endif
  let l:result = ""
  if !exists(a:varname)
    let l:result = input(a:prompt)

  endif
  return l:result
endfunction

" Get Text: {{{

" @brief  Get the selected text in visual mode
" @return string - visually selected text (including newlines)
" @see http://stackoverflow.com/a/6271254/794380 (original solution)
fun! g:PipeGetSelectedText()
  " Why is this not a built-in Vim script function?!
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  " echo join(lines, "\n")
  return join(lines, "\n")
endfun

" @brief Get a line of text
" @return string - a whole line where the cursor is currently at
fun! g:PipeGetCurrentLine()
  return getline('.')
endfun


" @brief Get a word
" @return string - a whole word where the cursor is currently at
fun! g:PipeGetCurrentWord()
  return expand("<cword>")
endfun

" }}}

" vim: foldmethod=marker
