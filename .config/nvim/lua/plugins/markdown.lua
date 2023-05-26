-- Markdown Preview
local MARKDOWN_PREVIEW = { 'iamcco/markdown-preview.nvim', build = 'cd app && yarn install' }
-- Preview markdown in vim
local GLOW = {
  'ellisonleao/glow.nvim',
  config = function()
    require('glow').setup()
  end
}

return {MARKDOWN_PREVIEW, GLOW}
