local u = require 'utils'

local LUA_SNIP = { "L3MON4D3/LuaSnip", version = "v2.3", dependencies = { "saadparwaiz1/cmp_luasnip" } }
local NVIM_CMP = { 'hrsh7th/nvim-cmp', dependencies = {
  'neovim/nvim-lspconfig',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
}}

NVIM_CMP.config = function()
  local cmp = require'cmp'

  cmp.setup({
  snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' }, -- For luasnip users.
      }, {
        { name = 'buffer' },
      })
    })

  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  require('lspconfig')['lua_ls'].setup {
    capabilities = capabilities
  }
  require('lspconfig')['docker_compose_language_service'].setup {
    capabilities = capabilities
  }

  require('lspconfig')['dockerls'].setup {
    capabilities = capabilities
  }

  require('lspconfig')['elixirls'].setup {
    capabilities = capabilities
  }

  require('lspconfig')['eslint'].setup {
    capabilities = capabilities
  }

  require('lspconfig')['rubocop'].setup {
    capabilities = capabilities
  }

  require('lspconfig')['ruby_lsp'].setup {
    capabilities = capabilities
  }

  require('lspconfig')['solargraph'].setup {
    capabilities = capabilities
  }

  require('lspconfig')['sqlls'].setup {
    capabilities = capabilities
  }

  require('lspconfig')['ts_ls'].setup {
    capabilities = capabilities
  }
end

return { NVIM_CMP, LUA_SNIP }
