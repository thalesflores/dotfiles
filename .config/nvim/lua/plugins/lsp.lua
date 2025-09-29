local u = require("utils")
local nnoremap = u.nnoremap

local LSP_CONFIG = { "neovim/nvim-lspconfig" }
local MASON = { "williamboman/mason.nvim" }
local MASON_LSP_CONFIG = { "williamboman/mason-lspconfig.nvim" }
local HELM_LS = {
    "qvalentin/helm-ls.nvim",
    ft = "helm",
    config = {
        conceal_templates = {
            -- enable the replacement of templates with virtual text of their current values
            enabled = false,
        },
        indent_hints = {
            -- enable hints for indent and nindent functions
            enabled = true,
            -- show the hints only for the line the cursor is on
            only_for_current_line = true,
        },
    },
}

MASON.config = function()
    require("mason").setup()
end

-- show float with error
nnoremap("Z", vim.diagnostic.open_float, { desc = "Show the diagnostic in a float" })
nnoremap("S", function()
    local new_config = not vim.diagnostic.config().virtual_lines
    vim.diagnostic.config({ virtual_lines = new_config })
end, { desc = "Toggle diagnostic virtual_lines" })

-------------------------
-- LS personal configs --
-------------------------

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.api.nvim_get_runtime_file("", true),
                },
            },
            telemetry = { enable = false },
        },
    },
})

vim.lsp.config("eslint", {
    on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
        })
    end,
})

vim.lsp.config("helm_ls", {
    settings = {
        ["helm-ls"] = {
            yamlls = {
                path = "yaml-language-server",
            },
        },
    },
})

----------------------
----------------------
----------------------

MASON_LSP_CONFIG.config = function()
    require("mason-lspconfig").setup({
        ensure_installed = {
            "lua_ls",
            "docker_compose_language_service",
            "dockerls",
            "eslint",
            "rubocop",
            "ruby_lsp",
            "sqlls",
            "ts_ls",
            "yamlls",
        },
    })
end

local ELIXIR_TOOLS = {
    "elixir-tools/elixir-tools.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local elixir = require("elixir")
        local elixirls = require("elixir.elixirls")

        elixir.setup({
            nextls = { enable = true },
            elixirls = {
                enable = true,
                settings = elixirls.settings({
                    dialyzerEnabled = false,
                    enableTestLenses = false,
                }),
                on_attach = function(client, bufnr)
                    vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
                    vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
                    vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })
                end,
            },
            projectionist = {
                enable = true,
            },
        })
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
}

vim.lsp.enable("postgres_lsp")

return {
    LSP_CONFIG,
    MASON,
    MASON_LSP_CONFIG,
    ELIXIR_TOOLS,
    HELM_LS,
}
