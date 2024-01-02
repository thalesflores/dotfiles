local opt = vim.opt -- global settings options

-- Show function context when scrolling
--  'nvim-treesitter/nvim-treesitter-context',

-- highlight langs
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    -- enabling fold
    opt.foldmethod = 'expr'
    opt.foldexpr   = 'nvim_treesitter#foldexpr()'
    opt.foldenable = false

    require('nvim-treesitter.configs').setup({
      -- A list of parser names, or "all"
      ensure_installed = { "elixir", "eex", "heex", "erlang", "lua", "javascript", "typescript", "vim", "ruby" },

      highlight = {
        enable = true,
        use_languagetree = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      },

      indent = { enable = true }

    })
  end
}
