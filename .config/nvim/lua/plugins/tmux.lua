-- Restore session along with tmux-ressurect
local VIM_OBSESSION = { "tpope/vim-obsession" }

-- Creates or run commands from VIM on existing TMUX panes.
local VIMUX = { "benmills/vimux" }

-- tmux integration
local TMUX_NAVIGATOR = {
  "christoomey/vim-tmux-navigator",

  init = function()
    vim.g.tmux_navigator_no_mappings = true
    vim.g.tmux_navigator_no_wrap = true
  end,

  config = function()
    vim.keymap.set('n', '<C-h>', ':<C-U>TmuxNavigateLeft<CR>', { silent = true })
    vim.keymap.set('n', '<C-j>', ':<C-U>TmuxNavigateDown<CR>', { silent = true })
    vim.keymap.set('n', '<C-k>', ':<C-U>TmuxNavigateUp<CR>', { silent = true })
    vim.keymap.set('n', '<C-l>', ':<C-U>TmuxNavigateRight<CR>', { silent = true })
  end,
}

return { VIM_OBSESSION, VIMUX, TMUX_NAVIGATOR }
