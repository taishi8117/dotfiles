" Disable beep
set visualbell t_vb=
set noerrorbells

if has("unnamedplus")
    set clipboard=unnamedplus
else
    set clipboard=unnamed
endif

set mouse=a       " enable mouse
set shellslash    " use / as separator in Windows

set wildmenu wildmode=list:longest,full
set history=10000

set updatetime=300

" don't pass messages to |ins-completion-menu|
set shortmess+=c

" Always show the signcolumn
set signcolumn=yes
