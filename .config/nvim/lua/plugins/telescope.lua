local u = require 'utils'

local nnoremap = u.nnoremap

local TELESCOPE = {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    { 'nvim-lua/plenary.nvim', opt = true }
  }
}

TELESCOPE.config = function()
  local builtin = require('telescope.builtin')
  nnoremap('<leader>.', builtin.find_files, { desc = 'Lists and finds all files' })
  nnoremap('<leader>fg', builtin.live_grep, { desc = 'Opens search panel' })
  nnoremap('<leader>fs', builtin.grep_string,
    { desc = 'Searches for the string under your cursor in your current working directory' })
  nnoremap('<leader>bb', builtin.buffers, { desc = 'Lists buffers' })
  nnoremap('<leader>fh', builtin.help_tags, { desc = 'Lists all help tags `:...`' })

  -- LSP commands
  nnoremap('gd', builtin.lsp_definitions, { desc = 'Go to definition' })
  nnoremap('<leader>ds', builtin.lsp_document_symbols, { desc = 'Show all symbols in the current file' })
  nnoremap('<leader>rr', builtin.lsp_references, { desc = '' })


  require('telescope').setup({
    defaults = {
      file_ignore_patterns = { "node_modules", "_build", "deps", '.elixir_ls' }
    },
    extensions = {
        quicknote = {
            defaultScope = "CurrentBuffer",
        }
    }
  })

  require("telescope").load_extension("quicknote")
end

return TELESCOPE
