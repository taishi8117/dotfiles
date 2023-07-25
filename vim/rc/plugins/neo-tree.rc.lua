vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })
vim.cmd([[
    highlight! link NeoTreeDirectoryIcon NvimTreeFolderIcon
    highlight! link NeoTreeDirectoryName NvimTreeFolderName
    highlight! link NeoTreeSymbolicLinkTarget NvimTreeSymlink
    highlight! link NeoTreeRootName NvimTreeRootFolder
    highlight! link NeoTreeDirectoryName NvimTreeOpenedFolderName
    highlight! link NeoTreeFileNameOpened NvimTreeOpenedFile
]])

local function getTelescopeOpts(state, path)
    return {
        cwd = path,
        search_dirs = { path },
        attach_mappings = function(prompt_bufnr, map)
            local actions = require "telescope.actions"
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local action_state = require "telescope.actions.state"
                local selection = action_state.get_selected_entry()
                local filename = selection.filename
                if (filename == nil) then
                    filename = selection[1]
                end
                -- any way to open the file without triggering auto-close event of neo-tree?
                require("neo-tree.sources.filesystem").navigate(state, state.path, filename)
            end)
            return true
        end
    }
end

require('neo-tree').setup({
    source_selector = {
        winbar = true,
        statusline = false
    },
    close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    default_component_configs = {
        container = {
            enable_character_fade = true
        },
        indent = {
            indent_size = 1,
            padding = 1, -- extra padding on left hand side
            -- indent guides
            with_markers = true,
            indent_marker = "│",
            last_indent_marker = "└",
            highlight = "NeoTreeIndentMarker",
            -- expander config, needed for nesting files
            with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
        },
        icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "ﰊ",
            -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
            -- then these will never be used.
            default = "*",
            highlight = "NeoTreeFileIcon"
        },
        modified = {
            symbol = "[+]",
            highlight = "NeoTreeModified",
        },
        name = {
            trailing_slash = false,
            use_git_status_colors = true,
            highlight = "NeoTreeFileName",
        },
        git_status = {
            symbols = {
                -- Change type
                added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
                modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
                deleted   = "✖", -- this can only be used in the git_status source
                renamed   = "", -- this can only be used in the git_status source
                -- Status type
                untracked = "",
                ignored   = "",
                unstaged  = "",
                staged    = "",
                conflict  = "",
            }
        },
    },
    window = {
        position = "left",
        width = 30,
        mappings = {
            ["i"] = "open_split",
            ["s"] = "open_vsplit",
        }
    },
    nesting_rules = {},
    filesystem = {
        window = {
            mappings = {
                ["o"] = "system_open",
            },
        },
        filtered_items = {
            visible = true, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = true,
            hide_gitignored = true,
            hide_hidden = true, -- only works on Windows for hidden files/directories
        },
        follow_current_file = false, -- This will find and focus the file in the active buffer every
        -- time the current file is changed while the tree is open.
        group_empty_dirs = false, -- when true, empty folders will be grouped together
        hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
        -- in whatever position is specified in window.position
        -- "open_current",  -- netrw disabled, opening a directory opens within the
        -- window like netrw would, regardless of window.position
        -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
        use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
        commands = {
            telescope_find = function(state)
                local node = state.tree:get_node()
                local path = node:get_id()
                require('telescope.builtin').find_files(getTelescopeOpts(state, path))
            end,
            telescope_grep = function(state)
                local node = state.tree:get_node()
                local path = node:get_id()
                require('telescope.builtin').live_grep(getTelescopeOpts(state, path))
            end,
            system_open = function(state)
                local node = state.tree:get_node()
                local path = node:get_id()
                -- macOs: open file in default application in the background.
                -- Probably you need to adapt the Linux recipe for manage path with spaces. I don't have a mac to try.
                vim.api.nvim_command("silent !open -g " .. path)
                -- Linux: open file in default application
                vim.api.nvim_command(string.format("silent !xdg-open '%s'", path))
            end,
        }, -- instead of relying on nvim autocmd events.
    },
})
