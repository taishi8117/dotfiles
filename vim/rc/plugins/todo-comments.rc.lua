require("todo-comments").setup {
  signs = true, -- show icons in the signs column
  sign_priority = 8, -- sign priority
  -- keywords recognized as todo comments
  keywords = {
    FIX = {
      icon = " ", -- icon used for the sign, and in search results
      color = "error", -- can be a hex color, or a named color (see below)
      alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
      -- signs = false, -- configure signs for some keywords individually
    },
    TODO = { icon = " ", color = "todo" },
    HACK = { icon = " ", color = "warning" },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    AUDIT = { icon = " ", color = "hint" },
    AUDIT_NOTE = { icon = " ", color = "info" },
    AUDIT_ISSUE = { icon = " ", color = "error" },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", color = "info", alt = { "INFO" } },
    TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
  },
  colors = {
    error = { "DiagnosticError", "ErrorMsg", "#ea6962" },
    warning = { "DiagnosticWarn", "WarningMsg", "#e78a4e" },
    info = { "DiagnosticInfo", "#7daea3" },
    hint = { "DiagnosticHint", "#d8a657" },
    default = { "Identifier", "#7C3AED" },
    test = { "#d3869b" },
    todo = { "#a9b665" }
  },
  highlight = {
    pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
  },
  search = {
    pattern = [[\b(KEYWORDS)(\(.*\))?:]], -- ripgrep regex
  }
}
