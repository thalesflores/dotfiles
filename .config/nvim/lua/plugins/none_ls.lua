local NONE_LS = { "nvimtools/none-ls.nvim" }
local MASON_NULL_LS = {
  "jay-babu/mason-null-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "nvimtools/none-ls.nvim",
  }
}

NONE_LS.config = function()
  local none_ls = require("null-ls")
  none_ls.setup({})
end

MASON_NULL_LS.config = function()
  require("mason-null-ls").setup({
    automatic_installation = true,
    ensure_installed = { "stylua", "jq", "rubocop", "prettier", "sqlformat", "yamlfmt", "credo" },
    handlers = {}
  })
end

vim.api.nvim_create_user_command("Format", function()
    vim.schedule(function()
      vim.lsp.buf.format({ async = true })
    end)
  end,
  { desc = "Format current file", nargs = '*', bang = true }
)

return { NONE_LS, MASON_NULL_LS }
