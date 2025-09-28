#!/usr/bin/env bash
# lib/installers/nvim.sh - Install and configure Neovim with lazy.nvim

set -euo pipefail

# Source common functions
# shellcheck source=../common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Configuration
readonly NVIM_CONFIG_DIR="$HOME/.config/nvim"
readonly NVIM_DATA_DIR="$HOME/.local/share/nvim"
readonly NVIM_CACHE_DIR="$HOME/.cache/nvim"
readonly NVIM_SOURCE_DIR="$DOTFILES_DIR/nvim"

# Check if neovim is installed
check_nvim_installed() {
    if ! command_exists "nvim"; then
        log_error "Neovim is not installed. Please install it first with system_deps."
        return 1
    fi

    local nvim_version
    nvim_version=$(nvim --version | head -n1 | cut -d' ' -f2)
    log_info "Found Neovim version: $nvim_version"

    # Check if version is recent enough for lazy.nvim (0.8+)
    local major minor
    major=$(echo "$nvim_version" | cut -d. -f1)
    minor=$(echo "$nvim_version" | cut -d. -f2)

    if [[ $major -eq 0 && $minor -lt 8 ]]; then
        log_warn "Neovim version $nvim_version may be too old for lazy.nvim (requires 0.8+)"
        log_warn "Consider updating Neovim for best experience"
    fi
}

# Backup existing neovim configuration
backup_existing_config() {
    log_info "Backing up existing neovim configuration..."

    # shellcheck source=../backup.sh
    source "$(dirname "${BASH_SOURCE[0]}")/../backup.sh"
    backup_nvim_files
}

# Install pynvim for Python support
install_pynvim() {
    log_info "Installing pynvim for Python support..."

    if python3 -c "import pynvim" 2>/dev/null; then
        log_info "pynvim is already installed"
        return 0
    fi

    if python3 -m pip install --user pynvim; then
        log_success "pynvim installed successfully"
    else
        log_warn "Failed to install pynvim (Neovim Python features may not work)"
    fi
}

# Link neovim configuration
link_nvim_config() {
    log_info "Linking neovim configuration..."

    # Remove existing config if it's not a symlink to our directory
    if [[ -e "$NVIM_CONFIG_DIR" ]] && [[ ! -L "$NVIM_CONFIG_DIR" ]]; then
        log_info "Moving existing config to backup"
        backup_item "$NVIM_CONFIG_DIR" "nvim_config_replaced"
        rm -rf "$NVIM_CONFIG_DIR"
    elif [[ -L "$NVIM_CONFIG_DIR" ]] && [[ "$(readlink "$NVIM_CONFIG_DIR")" != "$NVIM_SOURCE_DIR" ]]; then
        log_info "Removing incorrect symlink"
        rm "$NVIM_CONFIG_DIR"
    fi

    # Create symlink to our config
    safe_symlink "$NVIM_SOURCE_DIR" "$NVIM_CONFIG_DIR"

    log_success "Neovim configuration linked"
}

# Create init.lua with lazy.nvim bootstrap
create_init_lua() {
    log_info "Creating init.lua with lazy.nvim bootstrap..."

    local init_lua="$NVIM_SOURCE_DIR/init.lua"

    cat > "$init_lua" << 'EOF'
-- init.lua - Neovim configuration with lazy.nvim

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    print("Installing lazy.nvim...")
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load core settings first
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    defaults = {
        lazy = true, -- Lazy load plugins by default
    },
    install = {
        missing = true, -- Install missing plugins on startup
        colorscheme = { "gruvbox-material", "habamax" }, -- Try to load one of these colorschemes when starting
    },
    checker = {
        enabled = true, -- Check for plugin updates
        notify = false, -- Don't notify about updates
    },
    change_detection = {
        enabled = true,
        notify = false,
    },
    performance = {
        rtp = {
            -- Disable some rtp plugins
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})

-- Load post-configuration
pcall(require, "core.post")
EOF

    log_success "init.lua created with lazy.nvim bootstrap"
}

# Create core configuration files
create_core_config() {
    log_info "Creating core configuration files..."

    local core_dir="$NVIM_SOURCE_DIR/lua/core"
    ensure_dir "$core_dir"

    # Create options.lua
    cat > "$core_dir/options.lua" << 'EOF'
-- core/options.lua - Neovim options

local opt = vim.opt

-- General
opt.mouse = "a"                  -- Enable mouse support
opt.clipboard = "unnamedplus"    -- Use system clipboard
opt.swapfile = false             -- Disable swapfile
opt.completeopt = "menuone,noinsert,noselect"

-- UI
opt.number = true               -- Show line numbers
opt.relativenumber = true       -- Show relative line numbers
opt.cursorline = true          -- Highlight current line
opt.signcolumn = "yes"         -- Always show sign column
opt.colorcolumn = "80"         -- Show column at 80 characters
opt.scrolloff = 8              -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8          -- Keep 8 columns left/right of cursor
opt.termguicolors = true       -- Enable 24-bit RGB colors

-- Search
opt.ignorecase = true          -- Ignore case in search
opt.smartcase = true           -- Override ignorecase if search contains capitals
opt.hlsearch = true            -- Highlight search results
opt.incsearch = true           -- Show search results while typing

-- Indentation
opt.tabstop = 4                -- Number of spaces tabs count for
opt.shiftwidth = 4             -- Size of an indent
opt.expandtab = true           -- Use spaces instead of tabs
opt.smartindent = true         -- Insert indents automatically

-- Splits
opt.splitright = true          -- Put new windows right of current
opt.splitbelow = true          -- Put new windows below current

-- Backup and undo
opt.backup = false             -- Don't create backup files
opt.writebackup = false        -- Don't create backup files
opt.undofile = true            -- Enable persistent undo
opt.undolevels = 10000         -- Maximum number of undos

-- Timing
opt.updatetime = 250           -- Faster completion
opt.timeoutlen = 300           -- Time to wait for mapped sequence

-- Fold
opt.foldmethod = "expr"        -- Use expression for folding
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false         -- Don't fold by default
EOF

    # Create keymaps.lua
    cat > "$core_dir/keymaps.lua" << 'EOF'
-- core/keymaps.lua - Key mappings

local keymap = vim.keymap.set

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General
keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
keymap("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
keymap("n", "<leader>x", "<cmd>x<cr>", { desc = "Save and quit" })

-- Clear search highlights
keymap("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Resize windows
keymap("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move lines
keymap("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
keymap("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
keymap("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
keymap("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
keymap("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
keymap("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Better indenting
keymap("v", "<", "<gv", { desc = "Unindent line" })
keymap("v", ">", ">gv", { desc = "Indent line" })

-- Buffer navigation
keymap("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Diagnostic keymaps
keymap("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
keymap("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
keymap("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
keymap("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
EOF

    # Create autocmds.lua
    cat > "$core_dir/autocmds.lua" << 'EOF'
-- core/autocmds.lua - Autocommands

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- General settings
local general = augroup("General", { clear = true })

-- Highlight on yank
autocmd("TextYankPost", {
    group = general,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
    group = general,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- Auto-resize splits when window is resized
autocmd("VimResized", {
    group = general,
    pattern = "*",
    command = "tabdo wincmd =",
})

-- Don't auto comment new lines
autocmd("BufEnter", {
    group = general,
    pattern = "*",
    command = "set fo-=c fo-=r fo-=o",
})

-- Go to last location when opening a buffer
autocmd("BufReadPost", {
    group = general,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Close some filetypes with <q>
autocmd("FileType", {
    group = general,
    pattern = {
        "qf",
        "help",
        "man",
        "notify",
        "lspinfo",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "PlenaryTestPopup",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = general,
    command = "checktime",
})

-- File type specific settings
local filetypes = augroup("FileTypes", { clear = true })

-- Set wrap and spell for text files
autocmd("FileType", {
    group = filetypes,
    pattern = { "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})
EOF

    log_success "Core configuration files created"
}

# Create basic plugins configuration
create_plugins_config() {
    log_info "Creating plugins configuration..."

    local plugins_dir="$NVIM_SOURCE_DIR/lua/plugins"
    ensure_dir "$plugins_dir"

    # Create main plugins file
    cat > "$plugins_dir/init.lua" << 'EOF'
-- plugins/init.lua - Plugin specifications for lazy.nvim

return {
    -- Colorscheme
    {
        "sainnhe/gruvbox-material",
        priority = 1000,
        config = function()
            vim.g.gruvbox_material_background = "medium"
            vim.g.gruvbox_material_foreground = "material"
            vim.g.gruvbox_material_better_performance = 1
            vim.cmd("colorscheme gruvbox-material")
        end,
    },

    -- Treesitter for syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" },
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "bash", "c", "html", "javascript", "json", "lua", "markdown",
                    "markdown_inline", "python", "query", "regex", "tsx", "typescript",
                    "vim", "yaml", "go", "rust",
                },
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- LSP Support
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright", "tsserver" },
            })

            local lspconfig = require("lspconfig")
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            -- Lua
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            })

            -- Python
            lspconfig.pyright.setup({ capabilities = capabilities })

            -- TypeScript
            lspconfig.tsserver.setup({ capabilities = capabilities })
        end,
    },

    -- Completion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                },
            })
        end,
    },

    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer" },
        },
        config = function()
            require("nvim-tree").setup({
                disable_netrw = true,
                hijack_netrw = true,
                view = { width = 30 },
                renderer = {
                    group_empty = true,
                    highlight_git = true,
                },
                filters = { dotfiles = false },
            })
        end,
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-u>"] = false,
                            ["<C-d>"] = false,
                        },
                    },
                },
            })
        end,
    },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        config = function()
            require("lualine").setup({
                options = {
                    theme = "gruvbox-material",
                    component_separators = "|",
                    section_separators = "",
                },
            })
        end,
    },

    -- Git signs
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "+" },
                    change = { text = "~" },
                    delete = { text = "_" },
                    topdelete = { text = "‾" },
                    changedelete = { text = "~" },
                },
            })
        end,
    },

    -- Auto pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },

    -- Comment toggle
    {
        "numToStr/Comment.nvim",
        keys = {
            { "gcc", mode = "n", desc = "Comment toggle current line" },
            { "gc", mode = { "n", "o" }, desc = "Comment toggle linewise" },
            { "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
            { "gbc", mode = "n", desc = "Comment toggle current block" },
            { "gb", mode = { "n", "o" }, desc = "Comment toggle blockwise" },
            { "gb", mode = "x", desc = "Comment toggle blockwise (visual)" },
        },
        config = function()
            require("Comment").setup()
        end,
    },
}
EOF

    log_success "Plugins configuration created"
}

# Test neovim configuration
test_nvim_config() {
    log_info "Testing neovim configuration..."

    # Test that nvim can start without errors
    if nvim --headless +qa 2>/dev/null; then
        log_success "Neovim configuration test passed"
    else
        log_warn "Neovim configuration test failed (configuration may still work)"
    fi
}

# Install plugins
install_plugins() {
    log_info "Installing neovim plugins..."

    # Run nvim headless to install plugins
    if nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
        log_success "Plugins installation initiated"
        log_info "Plugins will continue installing in background"
    else
        log_warn "Plugin installation may have failed"
        log_info "Plugins will auto-install on first nvim start"
    fi
}

# Verify installation
verify_installation() {
    log_info "Verifying neovim installation..."

    # Check config directory link
    if [[ ! -L "$NVIM_CONFIG_DIR" ]] || [[ "$(readlink "$NVIM_CONFIG_DIR")" != "$NVIM_SOURCE_DIR" ]]; then
        log_error "Neovim configuration not properly linked"
        return 1
    fi

    # Check init.lua exists
    if [[ ! -f "$NVIM_SOURCE_DIR/init.lua" ]]; then
        log_error "init.lua not found"
        return 1
    fi

    log_success "Neovim installation verification passed"
    return 0
}

# Show post-installation notes
show_notes() {
    echo
    log_info "=== Neovim Installation Complete ==="
    log_info "• Lazy.nvim plugin manager installed"
    log_info "• Modern Lua-based configuration"
    log_info "• Essential plugins configured:"
    log_info "  - Treesitter (syntax highlighting)"
    log_info "  - LSP support (Mason, lspconfig)"
    log_info "  - Completion (nvim-cmp)"
    log_info "  - File explorer (nvim-tree)"
    log_info "  - Fuzzy finder (telescope)"
    log_info "  - Git integration (gitsigns)"
    echo
    log_info "Next steps:"
    log_info "• Run 'nvim' to complete plugin installation"
    log_info "• Use ':Lazy' to manage plugins"
    log_info "• Use ':Mason' to manage LSP servers"
    log_info "• Use '<leader>e' to toggle file explorer"
    log_info "• Use '<leader>ff' to find files"
}

# Main installation function
main() {
    log_info "=== Installing Neovim with Lazy.nvim ==="

    # Pre-installation checks
    check_nvim_installed || return 1

    # Backup existing configuration
    backup_existing_config

    # Install pynvim
    install_pynvim

    # Create modern Lua configuration
    create_init_lua
    create_core_config
    create_plugins_config

    # Link configuration
    link_nvim_config || return 1

    # Test configuration
    test_nvim_config

    # Install plugins
    install_plugins

    # Verify installation
    verify_installation || return 1

    # Show completion notes
    show_notes

    log_success "Neovim installation completed successfully!"
    return 0
}

# Run main function
main "$@"