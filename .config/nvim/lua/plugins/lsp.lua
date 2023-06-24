local u = require 'utils'

local g = vim.g

local nnoremap = u.nnoremap
local inoremap = u.inoremap
local vnoremap = u.vnoremap

function _G.show_docs()
  local cw = vim.fn.expand('<cword>')
  if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
    vim.api.nvim_command('h ' .. cw)
  elseif vim.api.nvim_eval('coc#rpc#ready()') then
    vim.fn.CocActionAsync('doHover')
  else
    vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
  end
end

local ALE = { 'dense-analysis/ale', {} }
local COC_ELIXIR = { 'amiralies/coc-elixir', build = 'yarn install && yarn prepack' }
local COC = { 'neoclide/coc.nvim', brach = 'release', build = 'yarn install --frozen-lockfile' }


ALE.config = function()
  g.ale_fixers = { elixir = { 'mix_format' } }
  g.ale_linters = { elixir = { 'elixir-ls' }, ruby = { 'rubocop' }, javascript = { 'eslint' } }

  g.ale_fix_on_save = 1
  --using credo elixir
  g.ale_elixir_credo_strict = 1
end

COC.config = function()
  g.coc_global_extensions = { 'coc-elixir', 'coc-diagnostic' }
  -- format on save elixir projects
  g.mix_format_on_save = 1

  -- Add `:Format` command to format current buffer
  vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

  inoremap('<C-space>', "coc#refresh()", { desc = "Autocomplete using COC with ctrl+space", silent = true, expr = true, })
  nnoremap('gd', '<Plug>(coc-definition)', { silent = true })
  nnoremap('gt', '<Plug>(coc-type-definition)', { silent = true })
  nnoremap('gi', '<Plug>(coc-implementation)', { silent = true })
  nnoremap('gr', '<Plug>(coc-references)', { silent = true })

  nnoremap('<leader>rn', '<Plug>(coc-rename)', { silent = true })
  nnoremap('<leader>k', '<CMD>lua _G.show_docs()<CR>', { silent = true })
  nnoremap('<space>d', '<CMD><C-u>CocList diagnostics<cr>', { silent = true })

  nnoremap('<leader>co  ', '<CMD><C-u>CocList outline<CR>', { silent = true, desc = 'Show all funcs' })
  nnoremap('<leader>cd', '<CMD><C-u>CocDiagnostics<CR>', { silent = true, desc = 'Show file problems' })

  --Remap <C-f> and <C-b> for scroll float windows/popups.

  local float_opts = { silent = true, nowait = true, expr = true }
  nnoremap("<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', float_opts)
  nnoremap("<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', float_opts)
  inoremap("<C-f>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', float_opts)
  inoremap("<C-b>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', float_opts)
  vnoremap("<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', float_opts)
  vnoremap("<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', float_opts)
end

return { ALE, COC, COC_ELIXIR }
