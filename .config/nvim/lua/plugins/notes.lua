local u = require 'utils'

local nnoremap = u.nnoremap

-- personal notes for line, files etc
local QUICKNOTE = { "RutaTang/quicknote.nvim", dependencies = { "nvim-lua/plenary.nvim"}}

vim.api.nvim_create_user_command("NewNoteAtCurrentLine", function()
  require('quicknote').NewNoteAtCurrentLine()
end,
{ desc = "Create not to the current line", nargs = '*', bang = true})

vim.api.nvim_create_user_command("OpenNoteAtCurrentLine", function()
  require('quicknote').OpenNoteAtCurrentLine()
end,
{ desc = "Open the current line note", nargs = '*', bang = true})

vim.api.nvim_create_user_command("CreateAndOpenNoteAtCurrentLine", function()
  require('quicknote').NewNoteAtCurrentLine()
  vim.cmd(":sleep 300m")
  require('quicknote').OpenNoteAtCurrentLine()
end,
{ desc = "Create and open the current line note", nargs = '*', bang = true})


QUICKNOTE.config = function()
  local builtin = require('quicknote')

  nnoremap('<leader>sn', builtin.ToggleNoteSigns, { desc = 'Show note icons' })
  nnoremap('<leader>cl', ":NewNoteAtCurrentLine<CR>", { desc = 'Create not to the current line' })
  nnoremap('<leader>on', ":OpenNoteAtCurrentLine<CR>", { desc = 'Open the current line note' })
  nnoremap('<leader>nn', ":CreateAndOpenNoteAtCurrentLine<CR>", { desc = 'Open the current line note' })
  nnoremap('<leader>nd', builtin.DeleteNoteAtCurrentLine, { desc = 'Delete the line note' })
  nnoremap('<leader>ln', ":Telescope quicknote<CR>", { desc = 'List all notes in the current buffer' })


  require("quicknote").setup({
    sign = ""
  })


end

return { QUICKNOTE }
