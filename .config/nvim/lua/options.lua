local HOME = os.getenv("HOME")

local opt = vim.opt -- global settings options
local g = vim.g     -- global variables

-- set leader to space
g.mapleader = " "
g.maplocalleader = " "

-- color schema
vim.cmd('colorscheme nord')

-- font |>
opt.guifont = 'JetBrains Mono'

-- general
opt.mouse   = 'a'
opt.clipboard:append('unnamedplus') -- copy to clipboard from vim by default
opt.encoding       = "utf-8"
opt.swapfile       = false          -- don't use swapfile
opt.number         = true           -- show current line number
opt.relativenumber = true           -- show relative line numbers
opt.autoread       = true           -- set to auto read when a file is changed from the outside
opt.updatetime     = 200
opt.inccommand     = 'nosplit'
opt.ruler          = true
opt.list           = true      -- show white spaces
opt.listchars:append "space:⋅" -- show symbol as white space
opt.showmatch = true           -- show matching brackets when text indicator is over them
opt.backspace = 'eol,start,indent'
opt.whichwrap:append('h,l')    -- go to next/previous line when in its ends/beginning
opt.foldcolumn = '0'
opt.errorbells = false         -- no annoying sounds on errors
opt.visualbell = false         -- no annoying visual on errors
opt.tm         = 500           -- time to wait till complete comand
opt.laststatus = 2             -- always show the status line
opt.lazyredraw = true          -- faster scrolling
opt.cursorline = true

-- search options
opt.incsearch  = true
opt.hlsearch   = true     -- doesn't show search highlights
opt.ignorecase = true     -- ignore case when searching
opt.smartcase  = true     -- ..unless there's a capital
opt.shortmess:append('S') -- do not show search matches, the lualine is handling it

-- indentation
opt.ai          = true -- auto indent
opt.si          = true -- smart indent
opt.wrap        = true -- wrap lines

-- space instead of tab
opt.tabstop     = 2
opt.shiftwidth  = 2
opt.expandtab   = true

-- undo configs
opt.undofile    = true
opt.undodir     = HOME .. '/.vim/undo'
opt.undolevels  = 100 -- number of undo saved

-- show ruler in editor
opt.colorcolumn = '98'
vim.cmd('highlight ColorColumn guibg=DarkGray')

-- Set to auto read when a file is changed from the outside
vim.cmd 'au FocusGained,BufEnter * checktime'

-- Return to last edit position when opening files
vim.cmd [[
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
]]
