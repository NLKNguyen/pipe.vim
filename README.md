# pipe.vim
Plugin to simply pipe command line output into Vim for previewing

Included helper functions for easily obtaining user input when needed, getting text from the buffer, and so on to compose sophisticated autocommands.

# Install

Using [Vundle](https://github.com/VundleVim/Vundle.vim) plugin manager:
```VimL
Plugin 'NLKNguyen/pipe.vim'
```

# 1 Minute Tutorial (Basic)
### :Pipe echo 'any shell command output'
It will return the string `any shell command output` in a Preview or Quickfix window. 

Characters like % or # are escaped (i.e. % will not result in the filename. It's just plain % symbol)

| Behavior     | Using                                                 | Display window  |
| ---          | ---                                                   | ---             |
| Synchronous  | built-in                                              | Preview window  |
| Asynchronous | [vim-dispatch](https://github.com/tpope/vim-dispatch) | Quickfix window |

To toggle display window `:PipeToggleWindow`

**Default key mapping in Normal mode**

`_|` (underscore then pipe character): prompt the prefix `:Pipe ` into Vim command line

`__` (double underscore): toggle display window

See FAQ section for how to turn off default mappings and use your own


#### :PipeUse Dispatch
Then run the previous :Pipe command again, it will use :Dispatch command from vim-dispatch to run instead. It requires vim-dispatch to be installed prior and having an adapter like Tmux ready in order to run asynchronously. This is suitable for long-running shell command.

#### :PipeUse Default
Use the default synchronous behavior


# Advance
// TODO: add info

# Help
// TODO: add info

# FAQ

1. Turn off default key mappings and use your own
```VimL
  let g:pipe_no_mappings = 1

  " Use your key
  nmap _<bar> <Plug>PipePrompt
  nmap __ <Plug>PipeToggle

```

# License MIT
Copyright (c) Nguyen Nguyen
