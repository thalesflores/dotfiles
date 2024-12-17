vim.opt.termguicolors = true

require('keymaps')

require('package_manager')
require('lazy').setup('plugins')

require('options')

require('autocommands')
require('commands')
