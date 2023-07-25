" plugin related configs
" double ESC to switch search highlighting
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

" file manager
" nnoremap <silent><C-e> :NERDTreeToggle<CR>
" nnoremap <leader>e :NERDTreeFind<CR>
nnoremap <leader>e :Neotree source=filesystem reveal=true reveal_force_cwd=true toggle=true position=left<CR>
nnoremap <C-e> :Neotree source=filesystem toggle=true position=left<CR>
nnoremap <C-k> :Neotree source=buffers reveal=true reveal_force_cwd=true toggle=true position=left<CR>
nnoremap <C-l> :Neotree source=git_status reveal=true reveal_force_cwd=true toggle=true position=left<CR>

" terminal
nnoremap <C-t> :ToggleTermToggleAll<CR>
nnoremap <leader>t :ToggleTerm<CR>


" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

" quickrun
"nnoremap \r :cclose<CR>:write<CR>:QuickRun -mode n<CR>
"xnoremap \r :<C-U>cclose<CR>:write<CR>gv:QuickRun -mode v<CR>

" zen mode
nnoremap <leader>z :ZenMode<CR>
nnoremap <leader>ww :Twilight<CR>

" fzf
nnoremap <C-f> :Files<CR>
"nnoremap <C-g> :Rg<CR>
"nnoremap <C-l> :Buffers<CR>
nnoremap <leader>ft :Filetypes<CR>

" telescope
nnoremap <C-f> <cmd>Telescope find_files<CR>
nnoremap <C-g> <cmd>Telescope live_grep<CR>
nnoremap <leader>ru <cmd>Telescope oldfiles<CR>
nnoremap <leader>s <cmd>Telescope symbols<CR>
nmap <silent> go <cmd>Telescope aerial<CR>
nmap <silent> gm <cmd>Telescope marks<CR>
nmap <silent> gp <cmd>Telescope registers<CR>
nmap <silent> gt <cmd>TodoTelescope<CR>

" indent guide
nnoremap <leader>i <cmd>IndentGuidesToggle<CR>

" copilot
nnoremap <leader>cp :call ToggleCopilot()<CR>
imap <M-.> <Plug>(copilot-next)
imap <M-,> <Plug>(copilot-previous)
imap <silent><script><expr> <C-k> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

" fugitive
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gl :Gclog<CR>

" outline
nnoremap <leader>o :AerialToggle<CR>

" locationlist
nmap <C-n> :lnext<CR>
nmap <C-p> :lprevious<CR>

" terminal
tnoremap <Esc> <C-\><C-n>

" duck
nnoremap <leader>dd :lua require("duck").hatch('🐈')<CR>
nnoremap <leader>dc :lua require("duck").cook()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Custom Command
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command Q :q
command W :w
command Qa :qa
command QA :qa
command Wq :wq
command WQ :wq
command Vs :vs
command Sp :sp

" suda
command WS :w suda://%

" change working directory to the currently open file
" https://vi.stackexchange.com/questions/3674/change-working-directory-to-current-opened-file
command CD :cd %:h


""""""""""""""""""""
" Coc mappings
""""""""""""""""""""

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
" NOTE: overridden below
"nmap <silent> gd <Plug>(coc-definition)
"nmap <silent> gy <Plug>(coc-type-definition)
"nmap <silent> gi <Plug>(coc-implementation)
"nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> to scroll float windows/popups
"if has('nvim-0.4.0') || has('patch-8.2.0750')
"  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
"  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
"  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
"  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
"  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
"  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
"endif

" Use CTRL-S for selections ranges
" Requires 'textDocument/selectionRange' support of language server
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  COC settings override
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" CocSnippet
let g:coc_snippet_next = '<TAB>'
let g:coc_snippet_prev = '<S-TAB>'

" GoTo code navigation.
nmap <silent> gw <cmd>Telescope coc<CR>
nmap <silent> gd <cmd>Telescope coc definitions<CR>
nmap <silent> gy <cmd>Telescope coc type_definitions<CR>
nmap <silent> gi <cmd>Telescope coc implementations<CR>
nmap <silent> gr <cmd>Telescope coc references<CR>
nmap <silent> ga <cmd>Telescope coc diagnostics<CR>
nmap <silent> ge <cmd>Telescope coc workspace_diagnostics<CR>

nnoremap <silent><nowait> == :call CocActionAsync('format')<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  TELESCOPE MAPPING
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

lua << END
local actions = require("telescope.actions")

require("telescope").setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
                ["<C-b>"] = actions.preview_scrolling_up,
            },
        },
    },
})
END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  TELEKASTEN MAPPING
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"nnoremap <leader>zf :lua require('telekasten').find_notes()<CR>
"nnoremap <leader>zd :lua require('telekasten').find_daily_notes()<CR>
"nnoremap <leader>zg :lua require('telekasten').search_notes()<CR>
"nnoremap <leader>zz :lua require('telekasten').follow_link()<CR>
"nnoremap <leader>zT :lua require('telekasten').goto_today()<CR>
"nnoremap <leader>t :lua require('telekasten').goto_today()<CR>
"nnoremap <leader>zW :lua require('telekasten').goto_thisweek()<CR>
"nnoremap <leader>zw :lua require('telekasten').find_weekly_notes()<CR>
"nnoremap <leader>zn :lua require('telekasten').new_note()<CR>
"nnoremap <leader>zN :lua require('telekasten').new_templated_note()<CR>
"nnoremap <leader>zy :lua require('telekasten').yank_notelink()<CR>
"nnoremap <leader>zc :lua require('telekasten').show_calendar()<CR>
"nnoremap <leader>zC :CalendarT<CR>
"nnoremap <leader>zi :lua require('telekasten').paste_img_and_link()<CR>
"nnoremap <leader>zt :lua require('telekasten').toggle_todo()<CR>
"nnoremap <leader>zb :lua require('telekasten').show_backlinks()<CR>
"nnoremap <leader>zF :lua require('telekasten').find_friends()<CR>
"nnoremap <leader>zI :lua require('telekasten').insert_img_link({ i=true })<CR>
"nnoremap <leader>zp :lua require('telekasten').preview_img()<CR>
"nnoremap <leader>zm :lua require('telekasten').browse_media()<CR>
"nnoremap <leader>za :lua require('telekasten').show_tags()<CR>
"nnoremap <leader># :lua require('telekasten').show_tags()<CR>
"nnoremap <leader>zr :lua require('telekasten').rename_note()<CR>
"
"" on hesitation, bring up the panel
"nnoremap <leader>z :lua require('telekasten').panel()<CR>
"
"inoremap <leader>[ <cmd>:lua require('telekasten').insert_link({ i=true })<CR>
"inoremap <leader>zt <cmd>:lua require('telekasten').toggle_todo({ i=true })<CR>
"inoremap <leader># <cmd>lua require('telekasten').show_tags({i = true})<cr>
