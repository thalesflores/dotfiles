local u = require 'utils'

local nnoremap = u.nnoremap

local NVIM_TREE = {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" }
}

NVIM_TREE.config = function()
  nnoremap('<leader>b', ':NvimTreeToggle<CR>', { desc = 'Toggle file tree' })

  require('nvim-tree').setup({
    filters = {
      dotfiles = true,
      custom = { "_build", "deps" }
    }
  })
end

return NVIM_TREE
