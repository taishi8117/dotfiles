let g:quickrun_config = get(g:, 'quickrun_config', {})
let g:quickrun_config._ = {
      \ 'runner'    : 'vimproc',
      \ 'runner/vimproc/updatetime' : 60,
      \ 'outputter' : 'error',
      \ 'outputter/error/success' : 'buffer',
      \ 'outputter/error/error'   : 'quickfix',
      \ 'outputter/buffer/split'  : ':rightbelow 5',
      \ 'outputter/buffer/close_on_empty' : 1,
      \ }
" Close quickfix with q
au FileType qf nnoremap <silent><buffer>q :quit<CR>

" Close quickfix with \r + run
let g:quickrun_no_default_key_mappings = 1

autocmd BufRead,BufNewFile *_test.go set filetype=go.test
let g:quickrun_config['go.test'] = {'command' : 'go', 'exec' : ['%c test']}
let g:quickrun_config['go'] = {'command' : 'go', 'exec' : ['%c run']}
