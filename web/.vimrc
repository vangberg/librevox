try " read in your vimrc first
  source $REAL_HOME/.vimrc
catch /E484/
endtry

if has("autocmd")
 " Enabled file type detection
 " Use the default filetype settings from plugins
 " do language-dependent indenting as well.
 filetype plugin on
 filetype indent on
endif " has ("autocmd")

" This section returns to the last place you were in a file
" When you repoen it. Comment out to disable this behavior
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") 
  \| execute "normal g'\"" | endif
endif

syntax on
set backspace=indent,eol,start	" more powerful backspacing
set tabstop=2    " Set the default tabstop
set shiftwidth=2 " Set the default shift width for indents
set expandtab   " Make tabs into spaces (set by tabstop)
set smartcase		" Do case insensitive matching
set smarttab " Smarter tab levels
set ruler  " Show ruler
set textwidth=0		" Don't wrap lines by default
set pastetoggle=<F6> " F6 will toggle between paste and normal
                      " Insert mode
set history=50		" keep 50 lines of command line history

" Extra For Rails
let g:rubycomplete_rails = 1

" set background=dark " If you have a dark background, uncomment this

" For our local plugins and files
set runtimepath+=~/.vim
