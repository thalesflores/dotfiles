syntax on

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = "\<SPACE>"
let g:mapleader = "\<SPACE>"

" Copy to clipboard from vim by default
set clipboard+=unnamed

set number
set relativenumber

call plug#begin('~/.vim/plugged')
" Color schema
Plug 'joshdick/onedark.vim'

" autoformat
Plug 'dense-analysis/ale'

" ElixirLS
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'amiralies/coc-elixir', {'do': 'yarn install && yarn prepack'}

" Run tests
Plug 'vim-test/vim-test'

" elixir highlight
Plug 'elixir-editors/vim-elixir'

" Smart auto-complete and works nice with alchemist
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" file tree
Plug 'scrooloose/nerdTree'

" surrounding
Plug 'tpope/vim-surround'

" Add shortcuts for commenting block of codes.
Plug 'vim-scripts/tComment'

" closing braces and brackets
Plug 'jiangmiao/auto-pairs'

" Git wrapper
Plug 'tpope/vim-fugitive'

" custom info bar
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" highlight when use y
Plug 'machakann/vim-highlightedyank'

" Display Indentation line
Plug 'Yggdroot/indentLine'

" Plugin to enable vim to open the file in the spefic line
Plug 'bogado/file-line'

" file finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" search
Plug 'eugen0329/vim-esearch'
 
" Creates or run commands from VIM on existing TMUX panes.
Plug 'benmills/vimux'

" tmux integration
Plug 'christoomey/vim-tmux-navigator'

" auto add end in functions
Plug 'tpope/vim-endwise'

" fancy initial screen to vim
Plug 'mhinz/vim-startify'

" Easialy rename files using :Rename filename newfilename
Plug 'danro/rename.vim'

" Markdown Preview
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

" Quickly navigation among Elixir files
Plug 'tpope/vim-projectionist'
Plug 'c-brenn/fuzzy-projectionist.vim'
Plug 'andyl/vim-projectionist-elixir'

" JS TS and react highlight
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
call plug#end()

" Doesn't show search highlights
"set nohlsearch

" Set to auto read when a file is changed from the outside
set autoread
au FocusGained,BufEnter * checktime
""""""""""""""""""""""""""""""""
" window split commands
""""""""""""""""""""""""""""""""
" Create a vertical split
nmap <leader>w\ :vsplit<CR><C-w>l

" Create a horizontal split
nmap <leader>w- :split<CR><C-w>j


if has("nvim")
  set inccommand=nosplit
endif

"Always show current position
set ruler

" Ignore case when searching
set ignorecase

" Makes search act like search in modern browsers
set incsearch

" Show line number
set cursorline

" show identention
set listchars=tab:\|\ 
set lcs+=space:·
set list

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Show matching brackets when text indicator is over them
set showmatch

" Add a bit extra margin to the left
set foldcolumn=1

set updatetime=300

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

" config Y to copy till end of the line
nnoremap Y y$

" keeping the cursor in the screen cender when searching/cocant
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z

" move lines up/down
nnoremap <C-k> :m .-2<CR>==
nnoremap <C-j> :m .+1<CR>==
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" Copy relative path
nnoremap <leader>fr :let @+ = expand("%")<CR>

" Copy full path
nnoremap <leader>fp :let @+ = expand("%:p")<CR>

" Copy  file name
nnoremap <leader>fn :let @+ = expand("%:t")<CR>

" coc global
let g:coc_global_extensions = ['coc-elixir', 'coc-diagnostic']

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Linter setup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let g:ale_fixers  = {'elixir': ['mix_format'], 'ruby': ['standardrb']}
let g:ale_fixers  = {'elixir': ['mix_format']}
let g:ale_linters = {
  \ 'elixir': ['elixir-ls'], 
  \ 'ruby': ['rubocop'], 
  \ 'javascript': ['eslint'],
  \ }

" Set this variable to 1 to fix files when you save them.
let g:ale_fix_on_save = 1
" using credo elixir
let g:ale_elixir_credo_strict = 1

" spaces instead of tab
set tabstop=2 shiftwidth=2 expandtab

" Color schema
set termguicolors
colorscheme onedark

" set fira code |> 
set guifont=Fira\ Code:h18

" autocomplete with ctrl+space
inoremap <silent><expr> <C-space> coc#refresh()

" map completion to use <c+j>/<c+k>
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

" Use <leader>b for toggling NerdTree
noremap <leader>b :NERDTreeToggle<CR>

 " ---> to hide unwanted files <---
let NERDTreeIgnore = [ 'node_modules/', '_build', 'deps']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Fuzzy Finder
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction

command! ProjectFiles execute 'Files' s:find_git_root()

" Use <Leader>. to start searching always from project directory.
nnoremap <silent> <leader>. :ProjectFiles<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Buffer config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use <leader>bb to show buffer list
nnoremap <silent> <leader>bb :Buffers<cr>

" previous and next buffers
nnoremap <silent> <leader>b] :bnext<cr>
nnoremap <silent> <leader>b[ :bprevious<cr>

" Close the current buffer
map <leader>bk :bd<cr>

" Close all the buffers
map <leader>bK :bufdo bd<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" show ruler in the editor
set colorcolumn=98
highlight ColorColumn guibg=DarkGray


" Always show the status line
set laststatus=2

" Return to last edit position when opening files
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" set undo history
set undofile
set undodir=~/.vim/undo

" number of undo saved
set undolevels=500 

" multiple selector select all
let g:multi_cursor_select_all_word_key = '<C-S-l>'

" format on save
let g:mix_format_on_save = 1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => COC Setup 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Doesn't show search highlights
set nohlsearch
"GoTo code navigation
nmap <leader>g <C-o>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nmap <leader>rn <Plug>(coc-rename)

"show all diagnostics.
nnoremap <silent> <space>d :<C-u>CocList diagnostics<cr>

" Use K to show documentation in preview window.
nnoremap <silent> <leader>k :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Show all symbols
nnoremap <silent> <leader>co  :<C-u>CocList outline<CR>

command! -nargs=0 Format :call CocAction('format')

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM test
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set terminal to vim-test
" let g:test#strategy = 'vimux'
let g:test#strategy = 'neovim'

" Remap ESC to not close the test window.
tnoremap <Esc> <C-\><C-n>

" Thanks to remap above it's need to remap ESC to close FZF.
au TermOpen * tnoremap <Esc> <c-\><c-n>
au FileType fzf tunmap <Esc>
" let $FZF_DEFAULT_COMMAND = 'ag -g ""'

let g:test#preserve_screen = 1
let g:test#filename_modifier = ":."

" Vim-test key bindings
" nmap <silent> <leader>tt :TestFile<CR>
nmap <silent> <leader>tf :TestFile<CR>
" nmap <silent> <leader>ts :TestNearest<CR>
nmap <silent> <leader>tn :TestNearest<CR>
nmap <silent> <leader>ts :TestSuite<CR>
" nmap <silent> <leader>ta :TestSuite<CR>
nmap <silent> <leader>tl :TestLast<CR>
nmap <silent> <leader>tv :TestVisit<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" airline config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" esearch
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Open the search window in a vertical split and reuse it for all further searches.
let g:esearch = {}
let g:esearch.name = '[esearch]'
let g:esearch.win_new = {esearch -> esearch#buf#goto_or_open(esearch.name, 'vnew')}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" projectionist config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Elixir switch between test and code file
let g:projectionist_heuristics = {
    \      "lib/*.ex": {
    \        "alternate": "test/{}_test.exs",
    \        "type": "src"
    \      }	,
    \      "test/*_test.ex": {
    \        "alternate": "lib/{}.exs",
    \        "type": "src"
    \      }	
    \ }

" js highlight config
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_ngdoc = 1
let g:javascript_plugin_flow = 1
