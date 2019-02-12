try
  colorscheme jellybeans
catch /^Vim\%((\a\+)\)\=:E185/
  " deal with it
endtry
au ColorScheme * hi Normal ctermbg=none guibg=none
au ColorScheme * hi NonText ctermbg=none guibg=none
