require('nvim-treesitter.configs').setup {
  ensure_installed = {
      "c", "lua", "vim", "javascript", "typescript",
      "bash", "css", "dockerfile", "go", "html", "jq", "make", "markdown",
      "python", "regex", "rust", "toml", "yaml", "solidity", "sql", "terraform"
  },
  sync_install = true,
  highlight = {
    enable = true,
  },
}
