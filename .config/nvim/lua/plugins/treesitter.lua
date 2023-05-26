-- highlight langs
-- Show function context when scrolling
--  'nvim-treesitter/nvim-treesitter-context',

return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
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
