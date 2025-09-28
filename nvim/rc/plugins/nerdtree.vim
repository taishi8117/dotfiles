let g:NERDTreeNodeDelimiter = "\u00a0"
let g:NERDTreeShowHidden=1
let g:NERDTreeIgnore=['\.git$', '\.clean$', '\.swp$', '\.bak$', '\~$', '\.pyc$']
let g:NERDTreeShowBookmarks=1
let g:NERDTreeAutoDeleteBuffer = 1
" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif
