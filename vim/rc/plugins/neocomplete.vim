let g:neocomplete#enable_ignore_case = 1
let g:neocomplete#enable_smart_case = 1
"	let g:neocomplete#enable_complete_select = 1
let g:neocomplete#enable_auto_select = 0
if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns._ =	'\h\w*'
