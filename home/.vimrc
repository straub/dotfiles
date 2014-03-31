
" Gotta love that Monokai
colorscheme Monokai

" UTF-8 FTW
set encoding=utf-8
set termencoding=utf-8
set fileencodings=utf-8,latin1

" spaces, not tabs
set tabstop=8
set softtabstop=4
set shiftwidth=4
set expandtab

" highlight tabs and trailing whitespace
set list
set listchars=trail:·,tab:··

" mousewheel scroll
set mouse=a

" ack-style smartcase searching
set ignorecase
set smartcase

" open two files in split screen
if argc() == 2
  silent all
endif

