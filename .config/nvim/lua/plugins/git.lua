local u = require 'utils'

local nnoremap = u.nnoremap
--
-- See git commit messages easy
local GIT_MESSENGER = { 'rhysd/git-messenger.vim' }
local FUGITIVE = 'tpope/vim-fugitive'   -- Git wrapper
local OPEN_GH = { 'almo7aya/openingh.nvim' }
local NEO_GIT = {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",         -- required
    "nvim-telescope/telescope.nvim", -- optional
    "sindrets/diffview.nvim",        -- optional
    "ibhagwan/fzf-lua",              -- optional
  },
  config = true
}

GIT_MESSENGER.config = function()
  -- when run <Leader> + gm focus go to the pop-up always
  vim.g.git_messenger_always_into_popup = 'v:true'
  -- Show margins in the pop-up
  vim.g.git_messenger_floating_win_opts = { border = 'single' }
  vim.g.git_messenger_popup_content_margins = 'v:false'
end

OPEN_GH.config = function()
  nnoremap('<Leader>gf', ':OpenInGHFileLines <CR>', { desc = 'open file in GitHub directly',  silent = true, noremap = true })
end

return { FUGITIVE, GIT_MESSENGER, OPEN_GH, NEO_GIT }
