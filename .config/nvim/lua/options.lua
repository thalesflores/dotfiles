local opt = vim.opt -- global settings options
local g = vim.g -- global variables

-- set leader to space
g.mapleader = " "
g.maplocalleader = " "

-- color schema
opt.termguicolors = true
vim.cmd('colorscheme nord')

-- font
opt.guifont = 'Fira Code:h18' -- set fira code |>

-- general
opt.mouse = 'a'
opt.clipboard = 'unnamed' -- copy to clipboard from vim by default
opt.number = true -- show current line number
opt.relativenumber = true -- show relative line numbers
opt.hlsearch = false -- doesn't show search highlights
opt.autoread = true -- set to auto read when a file is changed from the outside
opt.updatetime = 200
opt.inccommand = 'nosplit'
opt.ruler = true
opt.ignorecase = true -- ignore case when searching
opt.smartcase  = true -- ..unless there's a capital
opt.incsearch =  true
opt.cursorline = true
opt.list = true -- show white spaces
opt.showmatch = true -- show matching brackets when text indicator is over them
opt.backspace = 'eol,start,indent'
opt.whichwrap = 'h,l' -- go to next/previous line when in its ends/beginning
opt.foldcolumn = '0'
opt.errorbells = false -- no annoying sounds on errors
opt.visualbell = false -- no annoying visual on errors
-- opt.tm = 500 -- time to wait till complete comand
opt.laststatus = 2 -- always show the status line

-- indentation
opt.ai =  true -- auto indent
opt.si = true -- smart indent
opt.wrap = true -- wrap lines

-- space instead of tab
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- undo configs
opt.undofile = true
opt.undodir = '~/.nvim/undo'
opt.undolevels = 500 -- number of undo saved

-- show ruler in editor
opt.colorcolumn = '98'
vim.cmd('highlight ColorColumn guibg=DarkGray')
