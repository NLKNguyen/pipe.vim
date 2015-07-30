" Plugin: Pipe
" Author: Nguyen Nguyen <NLKNguyen@MSN.com>
" License: MIT
" Origin: http://github.com/NLKNguyen/pipe.vim

if exists("g:loaded_pipedotvim") || &cp
  finish
endif
let g:loaded_pipedotvim = 1

" Main: {{{

" @brief Method name that decides Pipe behavior
let s:method = 'Default'

" @warning Experimental feature
" @brief Specify what method to be used for running the shell command
" @param string - predefined method name
fun! g:PipeUse(method)
  if a:method ==? 'Default' || a:method ==? 'Dispatch'
    let s:method = a:method
    cclose "close quickfix window
    pclose "close preview window
  else
    echo 'Unrecognized method `'. a:method .'`. ' .
          \ 'Try :PipeUse with method `Default` or `Dispatch'
  endif
endfun

" @brief command alias for g:PipeUse(method)
command! -nargs=1  PipeUse :call g:PipeUse("<args>")


" @brief The plugin's main function that calls the appropriate function
"        depending on s:method
" @param string - shell command
fun! g:Pipe(cmd)
  let l:shell_command = escape(a:cmd, '%#\')
  if s:method ==? 'Dispatch'
    call s:PipeDispatch(l:shell_command)
  else
    call s:PipeDefault(l:shell_command)
  endif
  let s:last_command = a:cmd
endfun

" @brief command alias for g:Pipe(cmd)
command! -nargs=1 -complete=shellcmd  Pipe :call g:Pipe(<f-args>)


" @brief Default Pipe behavior: blocking & using Preview window
" @param string - escaped shell commands
fun! s:PipeDefault(shell_command)
  echohl String | echon ' ¦ Pipe running... (press ctrl-c to abort)' | echohl None

  silent! exe "noautocmd botright pedit ¦"
  noautocmd wincmd P
  setlocal modifiable
  normal ggdG

  call s:Load_Pipe_Preview_Settings()

  set buftype=nofile
  silent! exe "noautocmd .! " . a:shell_command
  normal G
  setlocal nomodifiable
  noautocmd wincmd p
  redraw!
  echohl Comment | echon 'Pipe finished at ' . strftime("%H:%M:%S ") | echohl None
endfun

" @warning Experimental feature
" @brief Alternative Pipe behavior: non-blocking & using Quickfix window
" @param string - escaped shell commands
" @see vim-dispatch - https://github.com/tpope/vim-dispatch
fun! s:PipeDispatch(shell_command)
  au BufWinEnter quickfix setlocal statusline=

  "@brief a simple trick to force quickfix window always open
  let l:force_open_qf = " printf ''  && "

  exec ":Dispatch " . l:force_open_qf . a:shell_command
endfun


" @brief Rerun the last Pipe command
fun! g:PipeLast()
  if exists("s:last_command")
    call g:Pipe(s:last_command)
  endif
endfun

" @brief command alias for g:PipeLast()
command! -nargs=0 PipeLast :call g:PipeLast()

" }}}


" Preview Window Settings: {{{

" @brief Load default or user settings
fun! s:Load_Pipe_Preview_Settings()
  if !exists("s:loaded_pipe_preview_settings")
    let l:custom = {'linenumber' : 0, 'wordwrap' : 0, 'whitespace' : 0, 'colorcolumn' : 0}

    if exists("g:pipe_preview_override")
      let l:custom = g:pipe_preview_override
    endif

    if l:custom['linenumber']
      setlocal number
    else
      setlocal nonumber
    endif

    if l:custom['wordwrap']
      setlocal wrap
    else
      setlocal nowrap
    endif

    if l:custom['whitespace']
      setlocal list
    else
      setlocal nolist
    endif

    if !l:custom['colorcolumn']
      setlocal colorcolumn=
    endif

    let s:loaded_pipe_preview_settings = 1
  endif

endfun
"}}}


" Get Or Set Variables: {{{

" @brief Get variable value or Ask for input if variable doesn't exist
" @param variable - quoted string of the variable name
" @param prompt - prompt message for input (in case an input is needed)
" @param visibility [optional] - 0: hidden input;
"                                1: visible input (default);
"                               10: always prompt with hidden input;
"                               11: always prompt with visible input;
" @return value of the variable
fun! g:PipeGetVar(variable, prompt, ...)
  let l:value = ""

  let l:visibility = 1
  if a:0 == 1 "the number of optional arguments (...) is 1
    let l:visibility = a:1
  endif

  if exists(a:variable)
    if l:visibility == 11 "always prompt
      let l:value = g:PipeSetVar(a:variable, a:prompt, l:visibility)
    elseif l:visibility == 10 "always prompt with hidden input
      let l:value = g:PipeSetVar(a:variable, a:prompt, 0)
    else
      let l:value = {a:variable}
    endif
  else
    let l:value = g:PipeSetVar(a:variable, a:prompt, l:visibility)
  endif

  return l:value
endfun


" @brief Set variable value by asking for user input
" @param variable - quoted string of the variable name
" @param prompt - prompt message for input
" @return value of the input
fun! g:PipeSetVar(variable, prompt, ...)
  let l:value = ""

  if exists(a:variable)
    let l:value = {a:variable}
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

  let {a:variable} = l:value
  return l:value
endfun
" }}}


" Get Text For Composing Autocommands: {{{

" @brief  Get the selected text in visual mode
" @return string - visually selected text (including newlines)
" @see original solution - http://stackoverflow.com/a/6271254/794380
fun! g:PipeGetSelectedText()
  return join(g:PipeGetSelectedTextAsList(), "\n")
endfun

" @brief  Get the selected text in visual mode as List
" @return list - visually selected text as list
" @see original solution - http://stackoverflow.com/a/6271254/794380
fun! g:PipeGetSelectedTextAsList()
  " Why is this not a built-in Vim script function?!
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  if len(lines) == 0
    return []
  endif
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return lines
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


" Toggle Quickfix Or Preview Window: {{{
fun! g:PipeToggleWindow()
  if s:method ==? 'Dispatch'
    call g:PipeToggleQuickfix()
  else
    call g:PipeTogglePreview()
  endif
endfun

" @brief command alias for g:PipeToggleWindow()
command! -nargs=0 PipeToggleWindow :call g:PipeToggleWindow()
" }}}


" Toggle Preview Window: {{{
" @see TODO: Give credit to this solution on Stackoverflow
fun! g:PipeTogglePreview()
  if s:PreviewWindowOpened()
    :pclose
  else
    silent! exec "botright pedit ¦"
  endif
endfun

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


" Toggle Quickfix Window: {{{

" @brief Toggle quickfix window
" @see Steve Losh's tutorial - http://learnvimscriptthehardway.stevelosh.com/chapters/38.html
fun! g:PipeToggleQuickfix()
    if exists("s:quickfix_is_open") && s:quickfix_is_open
        cclose
        let s:quickfix_is_open = 0
        execute g:quickfix_return_to_window . "wincmd w"
    else
        let g:quickfix_return_to_window = winnr()
        copen
        let s:quickfix_is_open = 1
    endif
endfun
" }}}

" =============================================================================
" Mapping: {{{
noremap <Plug>PipePrompt :Pipe 
noremap <silent> <Plug>PipeLast :PipeLast<CR>
noremap <silent> <Plug>PipeToggle :PipeToggleWindow<CR>

if !exists("g:pipe_no_mappings") || ! g:pipe_no_mappings
  nmap _<bar>     <Plug>PipePrompt
  nmap <bar><bar> <Plug>PipeLast
  nmap __         <Plug>PipeToggle
endif
" }}}

" vim: foldmethod=marker
