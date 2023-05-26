-- See git commit messages easy
local GIT_MESSENGER = { 'rhysd/git-messenger.vim' }
local FUGITIVE = 'tpope/vim-fugitive'   -- Git wrapper

GIT_MESSENGER.config = function()
  -- when run <Leader> + gm focus go to the pop-up always
  vim.g.git_messenger_always_into_popup = 'v:true'
  -- Show margins in the pop-up
  vim.g.git_messenger_floating_win_opts = { border = 'single' }
  vim.g.git_messenger_popup_content_margins = 'v:false'
end

return { FUGITIVE, GIT_MESSENGER }
