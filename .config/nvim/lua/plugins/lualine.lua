-- custom info bar
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { { 'nvim-tree/nvim-web-devicons', opt = true } },
  config = function()
    require('lualine').setup({
      extensions = { 'lazy', 'nvim-tree' },
      options = {
        theme = 'nord',
        component_separators = { left = '|', right = '' },
      },
      sections = {
        lualine_b = { 'branch' },
        lualine_c = { 'filename', 'diff', 'diagnostics' },
        lualine_x = { 'searchcount', 'filetype' },
        lualine_y = { { '%p%%', icon = '≡' } },
        lualine_z = { { '%l/%L', icon = '' }, { '%c', icon = '℅' } },
      }
    })
  end
}
