-- highlight langs
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    -- install parsers
    require('nvim-treesitter').install {
      "elixir",
      "eex",
      "heex",
      "erlang",
      "lua",
      "javascript",
      "typescript",
      "vim",
      "ruby",
      "markdown",
      "markdown_inline"
    }

    -- enable treesitter highlighting for all installed parsers
    vim.api.nvim_create_autocmd('FileType', {
      pattern = {
        'elixir', 'eex', 'heex', 'erlang', 'lua',
        'javascript', 'typescript', 'vim', 'ruby',
        'markdown', 'markdown_inline',
      },
      callback = function()
        vim.treesitter.start()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- folding via treesitter (disabled by default)
    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.opt.foldenable = false

    -- load jbuilder files as ruby
    vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
      pattern = "*.json.jbuilder",
      callback = function()
        vim.bo.filetype = "ruby"
      end
    })
  end
}
