" Disable beep
set visualbell t_vb=
set noerrorbells

if $TMUX == ''
  set clipboard=unnamed,unnamedplus
  set clipboard+=autoselect
  set clipboard+=unnamed
endif


set mouse=a       " enable mouse
set shellslash    " use / as separator in Windows
