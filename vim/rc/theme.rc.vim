try
  " colorscheme jellybeans
  colorscheme gruvbox-material
catch /^Vim\%((\a\+)\)\=:E185/
  " deal with it
endtry
au ColorScheme * hi Normal ctermbg=none guibg=none
au ColorScheme * hi NonText ctermbg=none guibg=none

" Indicate 80th column
let &colorcolumn="80,120"
highlight ColorColumn ctermbg=235 guibg=#2c2d27
set termguicolors " this variable must be enabled for colors to be applied properly
