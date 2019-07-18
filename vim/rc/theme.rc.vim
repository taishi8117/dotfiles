try
  colorscheme jellybeans
catch /^Vim\%((\a\+)\)\=:E185/
  " deal with it
endtry
au ColorScheme * hi Normal ctermbg=none guibg=none
au ColorScheme * hi NonText ctermbg=none guibg=none

" Indicate 80th column
let &colorcolumn="80,".join(range(120,999),",")
highlight ColorColumn ctermbg=235 guibg=#2c2d27
