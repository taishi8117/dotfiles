" ==========================================================
" Editor setup
" ==========================================================

" For 256 color
set t_Co=256

set number         " display line number
set cursorline     " change cursorline color
set laststatus=2   " always display status bar
set cmdheight=1    " one line for message bar
set showmatch      " emphasize matching bracket
set helpheight=999 " maximize help window
set list           " show hidden characters
" hidden character settings
set listchars=tab:▸\ ,eol:↲,extends:❯,precedes:❮
set encoding=utf-8

" cursor settings

set backspace=indent,eol,start " enable backspace everywhere
set whichwrap=b,s,h,l,<,>,[,]  " wrap at beginning and end of liens
set scrolloff=8                " display eight lines above and below of cursor
set sidescrolloff=16           " display 16 characters right and left of cursor
set sidescroll=1               " one character increment for side scrolling
set wrap                       " return long sentence

" file settings

set confirm    " confirm before exit when an unsaved file exists
set hidden     " enable editing a file even when an unsaved file exists
set autoread   " reload file when it was modified by another program
set nobackup   " not making a backup file
set nowritebackup
set noswapfile " not making a swap file

" search / replace settings

set hlsearch   " highlight search string
set incsearch  " enable incremental search
set ignorecase " ignore case for search
set smartcase  " case-senstive search if mixed cases are specified
"set wrapscan   " back to the beginning of the file after last match
if has('nvim')
  set inccommand=split
endif

" tab / indent settings

set expandtab     " expand tabs to spaces
set tabstop=2     " number of spaces per tab
set shiftwidth=2  " shift width
set softtabstop=2
set autoindent
set smartindent

" folding
set foldmethod=indent
set foldlevel=99
