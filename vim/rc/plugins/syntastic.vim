let g:syntastic_always_populate_loc_list = 1
let g:syntastic_loc_list_height=5
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

let g:syntastic_python_checkers = ["flake8"]
let g:syntastic_quiet_messages = { 'regex': ['E111', 'E114', 'E129', 'E501'] }