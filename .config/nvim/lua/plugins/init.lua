return {
  {
  'shaunsingh/nord.nvim', lazy = false, priority = 1000 }, -- colorscheme
  'tpope/vim-surround',                                      -- surrounding
  'vim-scripts/tComment',                                    -- Add shortcuts for commenting block of codes.
  'jiangmiao/auto-pairs',                                    -- closing braces and brackets
  'tpope/vim-obsession',                                     -- Restore session along with tmux-ressurect
  'machakann/vim-highlightedyank',                           -- highlight when use y
  'bogado/file-line',                                        -- in to enable vim to open the file in the spefic line
  'eugen0329/vim-esearch',                                   -- search
  'benmills/vimux',                                          -- Creates or run commands from VIM on existing TMUX panes.
  'christoomey/vim-tmux-navigator',                          -- tmux integration
  'tpope/vim-endwise',                                       -- auto add end in functions
  'mhinz/vim-startify',                                      -- fancy initial screen to vim
  'tpope/vim-eunuch',                                        -- Easialy rename files using :Rename filename newfilename
  { 'fatih/vim-go', build = ':GoUpdateBinaries' },           -- Golang helpers

  -- Todo highligth and list
  {
    'folke/todo-comments.nvim',
    config = function()
      require("todo-comments").setup()
    end
  },

  -- highlight same words
  {
    "echasnovski/mini.cursorword",
    config = function()
      require('mini.cursorword').setup({ delay = 300 })
    end
  }
}
