" Disable beep
set visualbell t_vb=
set noerrorbells

if $TMUX == ''
  set clipboard=unnamed,unnamedplus
endif

set mouse=a       " enable mouse
set shellslash    " use / as separator in Windows

set wildmenu wildmode=list:longest,full
set history=10000
