" double ESC to switch search highlighting
"
nnoremap <silent><C-e> :NERDTreeToggle<CR>
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

" neocomplete
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

" neosnippet
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)

" quickrun
nnoremap \r :cclose<CR>:write<CR>:QuickRun -mode n<CR>
xnoremap \r :<C-U>cclose<CR>:write<CR>gv:QuickRun -mode v<CR>

" fzf
nnoremap <C-f> :Files<CR>

" fugitive
nnoremap <C-s> :Gstatus<CR>

" syntastic
nnoremap <C-w>E :SyntasticCheck<CR> :SyntasticToggleMode<CR>
