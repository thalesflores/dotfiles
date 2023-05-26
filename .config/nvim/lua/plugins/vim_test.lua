local u = require 'utils'
local g = vim.g

local nnoremap = u.nnoremap

local VIM_TEST = { 'vim-test/vim-test' }

VIM_TEST.config = function()
  -- g:['test#strategy'] = 'vimux'
  g['test#strategy'] = 'neovim'
  g['test#preserve_screen'] = 1
  g['test#filename_modifier'] = ":."

  nnoremap('<leader>tf', ':TestFile<CR>', { silent = true, desc = '' })
  nnoremap('<leader>tn', ':TestNearest<CR>', { silent = true, desc = '' })
  nnoremap('<leader>ts', ':TestSuite<CR>', { silent = true, desc = '' })
  nnoremap('<leader>tl', ':TestLast<CR>', { silent = true, desc = '' })
  nnoremap('<leader>tv', ':TestVisit<CR>', { silent = true, desc = '' })
end

return VIM_TEST
