let g:syntastic_always_populate_loc_list = 1
let g:syntastic_loc_list_height=5
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

let g:syntastic_python_checkers = ["flake8"]
let g:syntastic_quiet_messages = { 'regex': ['E111', 'E114', 'E129', 'E501'] }
" let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [],'passive_filetypes': [] }

" Removing golint for now because it's annoying
let g:syntastic_go_checkers = ['go', 'golint', 'govet', 'errcheck']
let g:syntastic_mode_map = {
\ "mode" : "active",
\ "active_filetypes" : ["go"],
\}
