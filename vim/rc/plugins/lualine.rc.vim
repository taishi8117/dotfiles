lua << END
-- https://github.com/nvim-lualine/lualine.nvim/blob/master/examples/evil_lualine.lua
-- Color table for highlights
-- stylua: ignore
local colors = {
  bg       = '#202328',
  fg       = '#bbc2cf',
  yellow   = '#ECBE7B',
  cyan     = '#008080',
  darkblue = '#081633',
  green    = '#98be65',
  orange   = '#FF8800',
  violet   = '#a9a1e1',
  magenta  = '#c678dd',
  blue     = '#51afef',
  red      = '#ec5f67',
}

require('lualine').setup({
    options = { 
        theme = 'jellybeans',
        section_separators = '',
        component_separators = ''
    },
    sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch', 
                {
                  'diff',
                  colored = true, -- Displays a colored diff status if set to true
                  diff_color = {
                    -- Same color values as the general color option can be used here.
                    added    = { fg = colors.green },    -- Changes the diff's added color
                    modified = { fg = colors.orange }, -- Changes the diff's modified color
                    removed  = { fg = colors.red }, -- Changes the diff's removed color you
                  },
                  symbols = {added = ' ', modified = ' ', removed = ' '}, -- Changes the symbols used by the diff.
                  source = nil, -- A function that works as a data source for diff.
                                -- It must return a table as such:
                                --   { added = add_count, modified = modified_count, removed = removed_count }
                                -- or nil on failure. count <= 0 won't be displayed.
                },
                {
                  'diagnostics',

                  -- Table of diagnostic sources, available sources are:
                  --   'nvim_lsp', 'nvim_diagnostic', 'coc', 'ale', 'vim_lsp'.
                  -- or a function that returns a table as such:
                  --   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
                  sources = { 'nvim_diagnostic', 'coc' },

                  -- Displays diagnostics for the defined severity types
                  sections = { 'error', 'warn', 'info', 'hint' },

                  diagnostics_color = {
                    -- Same values as the general color option can be used here.
                    error = { fg = colors.red }, -- Changes diagnostics' error color.
                    warn  = { fg = colors.yellow },  -- Changes diagnostics' warn color.
                    info  = { fg = colors.cyan },  -- Changes diagnostics' info color.
                    hint  = { fg = colors.violet },  -- Changes diagnostics' hint color.
                  },
                  symbols = {error = ' ', warn = ' ', info = ' ', hint = ' '},
                  colored = true,           -- Displays diagnostics status in color if set to true.
                  update_in_insert = false, -- Update diagnostics in insert mode.
                  always_visible = false,   -- Show diagnostics even if there are none.
                }
            },
            lualine_c = {'filename'},
            lualine_d = {'g:coc_status', 'bo:filetype'},
            lualine_x = {'encoding', 'fileformat', 'filetype'},
            lualine_y = {'progress'},
            lualine_z = {'location'}
    },
})
END
