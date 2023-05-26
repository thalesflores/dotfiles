local g = vim.g

-- Quickly navigation among files
local PROJECTIONIST = {'tpope/vim-projectionist'}
local FUZZY_PROJECTIONIST = 'c-brenn/fuzzy-projectionist.vim'
local PROJECTIONIST_ELIXIR = 'andyl/vim-projectionist-elixir'

PROJECTIONIST.config = function()
  local heuristics = {
    ['lib/*.ex'] = { alternate = 'test/{}_test.exs', type = 'src' },
    ['test/*_test.ex'] = { alternate = 'lib/{}.exs', type = 'src' },
    ['app/models/*.rb'] = { type = 'model' },
    ['app/controllers/*.rb'] = { type = 'controller' },
    ['app/views/*.rb'] = { type = 'view' },
  }

  g.projectionist_heuristics = heuristics
end

return { PROJECTIONIST, FUZZY_PROJECTIONIST, PROJECTIONIST_ELIXIR }
