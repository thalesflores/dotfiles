local u = require 'utils'
local nnoremap = u.nnoremap

local LSP_CONFIG = { 'neovim/nvim-lspconfig' }
local MASON = { 'williamboman/mason.nvim' }
local MASON_LSP_CONFIG = { 'williamboman/mason-lspconfig.nvim' }

MASON.config = function()
  require("mason").setup()
end

-- show float with error
nnoremap('Z', vim.diagnostic.open_float, { desc = 'Show the diagnostic in a float' })
nnoremap('S', function()
  local new_config = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = new_config })
end, { desc = 'Toggle diagnostic virtual_lines' })

local lua_ls = function()
  local lspconfig = require("lspconfig")
  lspconfig.lua_ls.setup {
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc') then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using
          version = 'LuaJIT'
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            "${3rd}/luv/library"

          }
        }
      })
    end,
    settings = {
      Lua = {}
    }
  }
end

local docker_compose_language_service = function()
  require 'lspconfig'.docker_compose_language_service.setup {}
end

local dockerls = function()
  require 'lspconfig'.dockerls.setup {}
end

local elixirls = function()
  require 'lspconfig'.elixirls.setup {
    cmd = { "~/.elixir-ls/release/language_server.sh" },
  }
end

local eslint = function()
  require 'lspconfig'.eslint.setup({
    on_attach = function(client, bufnr)
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        command = "EslintFixAll",
      })
    end,
  })
end

local rubocop = function()
  require 'lspconfig'.rubocop.setup {}
end

local ruby_lsp = function()
  require 'lspconfig'.ruby_lsp.setup {}
end

local sqlls = function()
  require 'lspconfig'.sqlls.setup {}
end

local ts_ls = function()
  require 'lspconfig'.ts_ls.setup {}
end

MASON_LSP_CONFIG.config = function()
  require("mason-lspconfig").setup({
    ensure_installed = {
      "lua_ls",
      "docker_compose_language_service",
      "dockerls",
      "elixirls",
      "eslint",
      "rubocop",
      "ruby_lsp",
      "sqlls",
      "ts_ls",
    },
    handlers = {
      ["lua_ls"] = lua_ls,
      ["docker_compose_language_service"] = docker_compose_language_service,
      ["dockerls"] = dockerls,
      ["elixirls"] = elixirls,
      ["eslint"] = eslint,
      ["rubocop"] = rubocop,
      ["ruby_lsp"] = ruby_lsp,
      ["sqlls"] = sqlls,
      ["ts_ls"] = ts_ls,
    },
  })
end

return { MASON, MASON_LSP_CONFIG, LSP_CONFIG }
