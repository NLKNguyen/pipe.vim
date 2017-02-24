# pipe.vim
Simply pipe command line output into Vim for previewing

Can work alone or intergrate with other running interface such as [vim-dispatch](https://github.com/tpope/vim-dispatch), [asyncrun.vim](https://github.com/skywind3000/asyncrun.vim) 

Include helper functions to easily obtain user input when needed, get text from the buffer, and so on. Suitable for basing on in order to write other custom plugins such as [pipe-mysql](https://github.com/NLKNguyen/pipe-mysql.vim)

# Install

Using [Vundle](https://github.com/VundleVim/Vundle.vim) plugin manager:
```VimL
Plugin 'NLKNguyen/pipe.vim'
```

# Sample Usage
## :Pipe echo 'any shell command output'
It will return the string `any shell command output` in a Preview window.

Characters like % or # are escaped (i.e. % will not result in the filename. It's just plain % symbol)

**Default key mappings in Normal mode**

`_|` (underscore then pipe character): prompt the prefix `:Pipe ` into Vim command line

`||` (double pipe): rerun the last Pipe command

`__` (double underscore): toggle display window


To turn off default key mappings and use your own:
```VimL
  let g:pipe_no_mappings = 1

  " Use your key
  nmap _<bar>     <Plug>PipePrompt
  nmap <bar><bar> <Plug>PipeLast
  nmap __         <Plug>PipeToggle
```

## :PipeUse [interface]

Where `[interface]` is the target running interface.


`:PipeUse Default` will set the running interface to be default / **synchronously** (no dependencies, just Vim). Output will be piped into Preview window within Vim

`:PipeUse Dispatch` will use Dispatch plugin, and your command can run **asynchronously** (using an adapter such as tmux or screen). Output will be piped into QuickFix window within Vim. See [vim-dispatch](https://github.com/tpope/vim-dispatch) documentation for more information.

`:PipeUse AsyncRun` will use AsyncRun plugin, and your command can run **asynchronously** (Vim 7.4.1829 or later / NeoVim 0.1.4 or later). Output will be piped into QuickFix window within Vim. See [asyncrun.vim](https://github.com/skywind3000/asyncrun.vim) documentation for more information.

## :PipeToFile [file name]  

`:PipeToFile output.txt` will make the command output be piped into the given file name instead of capturing inside Vim. A window will popup to notify when the file is written.

`:PipeToFile` without providing a file name will turn off writing to file, and the ouput will be piped into Vim window normally.

# Helper Functions
These are simple and convenient functions that can be used to build sophisticated Pipe command. The MySQL client plugin [pipe-mysql.vim](https://github.com/NLKNguyen/pipe-mysql.vim) is an example that takes advantage of these.

### g:PipeGetVar(variable, prompt, ...)
    @brief Get variable value or Ask for input if variable doesn't exist
    @param variable - quoted string of the variable name
    @param prompt - prompt message for input (in case an input is needed)
    @param visibility [optional] - 0: hidden input;
                                   1: visible input (default);
                                  10: always prompt with hidden input;
                                  11: always prompt with visible input;
    @return value of the variable

### g:PipeSetVar(variable, prompt, ...)
    @brief Set variable value by asking for user input
    @param variable - quoted string of the variable name
    @param prompt - prompt message for input
    @return value of the input

### g:PipeGetCurrentWord()
    @brief Get a word
    @return string - a whole word where the cursor is currently at

### g:PipeGetCurrentLine()
    @brief Get a line of text
    @return string - a whole line where the cursor is currently at

### g:PipeGetSelectedText()
    @brief  Get the selected text in visual mode
    @return string - visually selected text (including newlines)

### g:PipeGetSelectedTextAsList()
    @brief  Get the selected text in visual mode
    @return list - visually selected text as list;
                   useful for writing to file

-------
Suggestions/Wishes/Questions/Comments are welcome via [Github issues](https://github.com/NLKNguyen/pipe.vim/issues)

# License MIT
Copyright (c) Nguyen Nguyen
