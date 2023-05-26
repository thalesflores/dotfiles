local u = require('utils')
local nnoremap = u.nnoremap

local g = vim.g

--Database plugs
local DADBOD = { 'tpope/vim-dadbod' }
local DADBOD_UI = 'kristijanhusak/vim-dadbod-ui'

DADBOD.config = function()
  nnoremap('<leader>du', ':DBUIToggle<CR>', { silent = true })
  nnoremap('<leader>df', ':DBUIFindBuffer<CR>', { silent = true })
  nnoremap('<leader>dr', ':DBUIRenameBuffer<CR>', { silent = true })
  nnoremap('<leader>dl', ':DBUILastQueryInfo<CR>', { silent = true })
  g.db_ui_save_location = '~/.config/nvim/db_ui'
end

return { DADBOD, DADBOD_UI }
