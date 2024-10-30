-- Markdown Preview
local MARKDOWN_PREVIEW = {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && yarn install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
}
-- Preview markdown in vim
local GLOW = {
  'ellisonleao/glow.nvim',
  config = function()
    require('glow').setup()
  end
}

-- Better markdown view in the editor
local MARKVIEW = {
  "OXY2DEV/markview.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons"
  }
}


return { GLOW, MARKDOWN_PREVIEW, MARKVIEW }
