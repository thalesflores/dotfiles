local u = require 'utils'

local noremap = u.noremap
local nnoremap = u.nnoremap
local inoremap = u.inoremap
local tnoremap = u.tnoremap
local vnoremap = u.vnoremap
local map_bang = u.map_bang

--  set leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Dumb mappings
nnoremap(':W', ':w', { desc = 'Save with :W too cause I am dumb and use it all the time' })

-- enabling the ç and Ç
map_bang('<A-c>', '<C-k>c,', { desc = 'Enables the usage of ç' })
map_bang('<A-C>', '<C-k>C,', { desc = 'Enables the usage of Ç' })


-- window split commands
nnoremap('<leader>w\\', ":vsplit<CR><C-w>l", { desc = 'Creates a vertical split' })
nnoremap('<leader>w-', ":split<CR><C-w>j", { desc = 'Creates a horizontal split' })

-- terminal interaction commands
tnoremap('<Esc>', '<C-\\><C-n>', { desc = 'ESC does not close the terminal window.' })

-- spell commands
nnoremap('<C-s>o', ':set spell spelllang=en_us<CR>', { desc = 'Turns on the English spellcheck' })
nnoremap('<C-s>f', ':set nospell<CR>', { desc = 'Turns off the spellcheck' })

-- copying & yanking
nnoremap('Y', 'y$', { desc = 'Configs Y to copy till end of the line' })

nnoremap('<leader>fn', ':let @+ = expand("%:t")<CR>', { desc = 'Copies file name' })
nnoremap('<leader>fr', ':let @+ = expand("%")<CR>', { desc = 'Copies relative path' })
nnoremap('<leader>fp', ':let @+ = expand("%:p")<CR>', { desc = 'Copies full path' })


-- keeping the cursor in the screen's center
nnoremap('n', "nzzzv", { desc = 'Keeps cursor in the center when go to next search result' })
nnoremap('N', "Nzzzv", { desc = 'Keeps cursor in the center when go to previous search result' })
nnoremap('J', "mzJ`z", { desc = 'Keeps cursor in the center concating lines' })

-- move lines up/down
nnoremap('<A-k>', ':m .-2<cr>==', { desc = 'Moves current line up in normal mode' })
vnoremap('<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Moves current line up in visual mode' })

nnoremap('<A-j>', ':m .+1<cr>==', { desc = 'Moves current line down in normal mode' })
vnoremap('<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Moves current line down in visual mode' })

-- search
nnoremap('<C-s>', '<CMD>noh<CR>', { desc = 'Clears search highlith till next search' })

-- buffers

--noremap('<silent> <leader>bb', ':Buffers<cr>', {desc = 'Shows buffer list'})

noremap('<leader>b]', "<CMD>bn<CR>", { desc = 'Goes to next buffer' })
noremap('<leader>b[', "<CMD>bp<CR>", { desc = 'Goes to previous buffer' })

nnoremap('<leader>bk', ':bd<cr>', { desc = 'Closes the current buffer' })
nnoremap('<leader>bK', ':bufdo bd<cr>', { desc = 'Closes all the buffers' })
nnoremap('<leader>bo', ':up | %bd | e#<cr>', { desc = 'Closes all other buffers, but the current one' })
