function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
  vim.keymap.set('t', '<C-q>', [[<C-\><C-n>20<C-w>_]], opts)
  vim.keymap.set('n', '<C-q>', [[<C-\><C-n>20<C-w>_]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd([[
    autocmd TermEnter term://*toggleterm#*
      \ tnoremap <silent><c-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>
    autocmd! TermOpen term://* lua set_terminal_keymaps()

    nnoremap <silent><c-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>
    inoremap <silent><c-t> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>
]])

require('toggleterm').setup({
    size = 20,
    start_in_insert = false,
    open_mapping = [[<c-.>]]
})

local Terminal  = require('toggleterm.terminal').Terminal

-- local lazygit = Terminal:new({
--   cmd = "lazygit",
--   dir = "git_dir",
--   direction = "float",
--   float_opts = {
--     border = "double",
--   },
--   hidden = true,
-- 
--   -- function to run on opening the terminal
--   on_open = function(term)
--     vim.cmd("startinsert!")
--     vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
--   end,
--   close_on_exit = true,
--   -- function to run on closing the terminal
--   on_close = function(term)
--     vim.cmd("startinsert!")
--   end,
-- })
-- 
-- function _lazygit_toggle()
--   lazygit:toggle()
-- end
-- 
-- vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})
