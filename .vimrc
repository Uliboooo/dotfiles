" Basic config
set relativenumber
set number
set list
set listchars=tab:»-,trail:~,nbsp:␣
set wrap
set linebreak
set clipboard=unnamedplus
set hlsearch
set tabstop=2
set shiftwidth=2
set expandtab
set termguicolors
set updatetime=1000
set cursorline
set mouse=a
set signcolumn=yes
set colorcolumn=100
set autoread
set laststatus=2
set noshowmode
set ttimeoutlen=50

" 不可視文字のハイライト
highlight DangerousChars ctermbg=red guibg=red
match DangerousChars /[\u200B\u200C\u200D\uFEFF\u202E\u2066-\u2069]/

" 自動読み込み設定
autocmd FocusGained,BufEnter * checktime

" 2. プラグイン管理
call plug#begin('~/.vim/plugged')

" 外観
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'itchyny/lightline.vim'
Plug 'luochen1990/rainbow'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Plug 'voldikss/vim-floaterm'

call plug#end()

" 構文ハイライト
syntax on
filetype plugin indent on

" 3. カラースキームと外観設定 (visual.lua / config.lua より)
colorscheme catppuccin_macchiato

let g:lightline = {'colorscheme': 'catppuccin_macchiato'}

" 背景透過設定
highlight Normal guibg=NONE ctermbg=NONE
highlight NormalNC guibg=NONE ctermbg=NONE
highlight SignColumn guibg=NONE ctermbg=NONE
highlight LineNr guibg=NONE ctermbg=NONE
highlight EndOfBuffer guibg=NONE ctermbg=NONE

" Lo-fi Aesthetic風カスタムハイライト (config.lua)
let s:lofi = {
      \ 'base': '#232136',
      \ 'mantle': '#2a273f',
      \ 'text': '#e0def4',
      \ 'border': '#44415a',
      \ 'rose': '#ea9a97',
      \ 'cyan': '#3e8fb0'
      \ }

execute 'highlight ColorColumn guifg=' . s:lofi.border . ' guibg=NONE'
execute 'highlight CursorLine guibg=' . s:lofi.mantle
execute 'highlight CursorLineNr guifg=' . s:lofi.rose . ' guibg=' . s:lofi.mantle . ' gui=bold'
execute 'highlight Pmenu guifg=' . s:lofi.text . ' guibg=' . s:lofi.mantle
execute 'highlight PmenuSel guifg=' . s:lofi.base . ' guibg=' . s:lofi.rose
execute 'highlight Search guifg=' . s:lofi.base . ' guibg=' . s:lofi.cyan . ' gui=bold'

if !has('nvim')
  let &t_SI = "\e[5 q"
  let &t_SR = "\e[3 q"
  let &t_EI = "\e[2 q"
endif

let mapleader = " "

" LSP関連 (Coc.nvim)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>r <Plug>(coc-rename)
nmap <leader>a <Plug>(coc-codeaction-selected)
nnoremap <silent> K :call CocActionAsync('doHover')<CR>

" 補完決定 (Enterで確定)
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"


" 検索ハイライト消去
nnoremap <leader>n :nohlsearch<CR>

" Redo
nnoremap <leader>U <C-r>

" コメントアウト (vim-commentary)
nmap <C-c> gcc
vmap <C-c> gc

" FZF (Telescopeのキーマップを移植)
nnoremap <leader>f :Files<CR>
nnoremap <leader>/ :Rg<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>d :Diagnostics<CR>

" ターミナル (Floaterm)
" nnoremap <silent> <C-\> :FloatermToggle<CR>
" nnoremap <silent> <F12> :FloatermToggle<CR>
" tnoremap <silent> <C-\> <C-\><C-n>:FloatermToggle<CR>
" tnoremap <silent> <F12> <C-\><C-n>:FloatermToggle<CR>
" nnoremap <leader><CR> :FloatermNew --autoclose=1 cargo run<CR>

" 5. 自動整形 (conform.lua より)
" Coc.nvimを使用した保存時フォーマット設定
autocmd BufWritePre *.c,*.cpp,*.h,*.hpp,*.rs,*.go silent! call CocAction('format')
