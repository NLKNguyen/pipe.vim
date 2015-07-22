" Plugin: Pipe
" Author: Nguyen Nguyen <NLKNguyen@MSN.com>
" License: MIT
" Origin: http://github.com/NLKNguyen/pipe.vim

" Main: {{{

" @brief Method name that decides Pipe behavior
let s:method = 'Default'

" @brief Specify what method to be used for running commands
" @param string - predefined method name
fun! g:PipeUse(method)
  if a:method ==? 'Default' || a:method ==? 'Dispatch'
    let s:method = a:method
  else
    echo 'Unrecognized method `'. a:method .'`. ' .
          \ 'Try :PipeUse with method `Default` or `Dispatch'
  endif
endfun

" @brief command alias for g:PipeUse(method)
command! -nargs=1  PipeUse :call g:PipeUse("<args>")


" @brief The plugin's main function that calls the appropriate function
"        depending on s:method
" @param string - shell commands
fun! g:Pipe(cmd)
  let l:shell_commands = escape(a:cmd, '%#\')
  if s:method ==? 'Dispatch'
    call s:PipeDispatch(l:shell_commands)
  else
    call s:PipeDefault(l:shell_commands)
  endif
endfun

" @brief command alias for g:Pipe(cmd)
command! -nargs=1 -complete=shellcmd  Pipe :call g:Pipe(<f-args>)


" @brief Default Pipe behavior: blocking & using Preview window
" @param string - escaped shell commands
fun! s:PipeDefault(shell_commands)
  echohl String | echon 'Pipe running... (press ctrl-c to abort)' | echohl None

  silent! exe "noautocmd botright pedit ¦"
  noautocmd wincmd P
  setlocal modifiable
  normal ggdG

  call s:Load_Pipe_Preview_Settings()

  set buftype=nofile
  silent! exe "noautocmd .! " . a:shell_commands
  normal G
  setlocal nomodifiable
  noautocmd wincmd p
  echohl Comment | echon 'Pipe finished at ' . strftime("%H:%M:%S ") | echohl None
endfun

" @brief Alternative Pipe behavior: non-blocking & using Quickfix window
" @param string - escaped shell commands
" @see vim-dispatch - https://github.com/tpope/vim-dispatch
fun! s:PipeDispatch(shell_commands)
  exec ":Dispatch " . a:shell_commands
endfun

" }}}


" Preview Window Settings: {{{
" Default settings (can be set by users)
let g:Pipe_Preview_LineNr = 0
let g:Pipe_Preview_Wrap   = 0

" TODO: use dictionary like this instead
" let g:Pipe_Preview_Override = {'linenumber' : 0, 'wordwrap' : 0}

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
fun! g:PipeGetVar(varname, prompt, ...)
  let l:value = ""

  let l:visibility = 1
  if a:0 == 1 "the number of optional arguments (...) is 1
    let l:visibility = a:1
  endif

  if !exists(a:varname)
    call g:PipeSetVar(a:varname, a:prompt, l:visibility)
  endif

  let l:value = {a:varname}

  return l:value
endfun


fun! g:PipeSetVar(varname, prompt, ...)
  let l:value = ""

  if exists(a:varname)
    let l:value = {a:varname}
  endif

  let l:visibility = 1
  if a:0 == 1 "the number of optional arguments (...) is 1
    let l:visibility = a:1
  endif

  call inputsave()

  if l:visibility == 0
    let l:value = inputsecret(a:prompt)
  else
    let l:value = input(a:prompt, l:value)
  endif

  call inputrestore()

  let {a:varname} = l:value
endfun
" }}}


" Get Text: {{{

" @brief  Get the selected text in visual mode
" @return string - visually selected text (including newlines)
" @see original solution - http://stackoverflow.com/a/6271254/794380
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

" Toggle Preview Window: {{{
fun! g:PipeToggleWindow()
  if s:PreviewWindowOpened()
    :pclose
  else
    silent! exec "botright pedit ¦"
  endif
endfun
command! -nargs=0 PipeToggleWindow :call g:PipeToggleWindow()

fun! s:PreviewWindowOpened()
    for nr in range(1, winnr('$'))
        if getwinvar(nr, "&pvw") == 1
            " found a preview
            return 1
        endif
    endfor
    return 0
endfun
" }}}

" Mapping: {{{
noremap <unique> <Plug>PipePrefix :Pipe 
noremap <unique> <Plug>PipeToggle :PipeToggleWindow<CR>
" }}}

" vim: foldmethod=marker
