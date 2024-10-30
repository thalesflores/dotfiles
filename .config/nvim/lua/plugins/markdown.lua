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

return { GLOW, MARKDOWN_PREVIEW }
