" Disable beep
set visualbell t_vb=
set noerrorbells

set clipboard=unnamed,unnamedplus

set mouse=a       " enable mouse
set shellslash    " use / as separator in Windows

set wildmenu wildmode=list:longest,full
set history=10000

set updatetime=300

" don't pass messages to |ins-completion-menu|
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

