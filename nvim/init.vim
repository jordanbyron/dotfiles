let g:python_host_prog = '/usr/local/bin/python3'
let $NVIM_TUI_ENABLE_TRUE_COLOR=0
" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

Plug 'vim-ruby/vim-ruby'
Plug 'scrooloose/nerdtree'
" Plug 'ctrlpvim/ctrlp.vim'
Plug 'joshdick/onedark.vim'
Plug 'tpope/vim-commentary'
Plug 'airblade/vim-gitgutter'
Plug 'terryma/vim-multiple-cursors'
Plug 'rgarver/Kwbd.vim'
Plug 'tpope/vim-endwise'
Plug 'pangloss/vim-javascript'
Plug 'mileszs/ack.vim'
Plug 'neomake/neomake'
Plug 'janko-m/vim-test'
Plug 'tpope/vim-fugitive'
Plug 'jaawerth/nrun.vim'
Plug 'mustache/vim-mustache-handlebars'
Plug 'sgur/vim-editorconfig'
Plug 'slim-template/vim-slim'
Plug 'sbdchd/neoformat'
Plug 'github/copilot.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'williamboman/mason.nvim'
Plug 'neovim/nvim-lspconfig'
" Plug 'pmizio/typescript-tools.nvim'
" Plug 'folke/trouble.nvim'

" Plug 'jose-elias-alvarez/null-ls.nvim'
" Plug 'MunifTanjim/prettier.nvim'

" Plug 'zbirenbaum/copilot.lua'
" Plug 'nvim-lua/plenary.nvim'
" Plug 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'main' }

" gS to split a one-liner into multiple lines
" gJ (with the cursor on the first line of a block) to join a block into a single-line statement.

Plug 'AndrewRadev/splitjoin.vim'

" Use :Gsearch to get a buffer window of your search results
" then you can make the replacements inside the buffer window using traditional tools (%s/foo/bar/)
" Invoke :Greplace to make your changes across all files. It will ask you interatively y/n/a - you can hit 'a' to do all.
" Save changes to all files with :wall (write all)
"
Plug 'skwp/greplace.vim'

" Initialize plugin system
call plug#end()

" Config to write tmp files to a standard directory to keep docker happy
set directory=$HOME/.vim/tmp//
set backupdir=$HOME/.vim/tmp//
set undodir=$HOME/.vim/tmp//
set backupcopy=no

" Standard config

set ts=2
set shiftwidth=2
set expandtab
set autoindent
set mouse=a
set shortmess+=r
set ignorecase
set smartcase
set incsearch
set nohlsearch
set gdefault
set backspace=eol,start,indent
set wildmode=list:longest
set number
set ruler
set sm
set history=10000
set hidden
set showcmd
set splitbelow
set splitright
set winwidth=86 " approx 80 columns plus line numbers and marks sidebar
set list
set listchars=trail:•

let g:one_allow_italics = 1 " I love italic for comments
syntax on
colorscheme onedark

let mapleader=","

" NERD_Tree
map <leader>d :execute 'NERDTreeToggle ' . getcwd()<CR>

" Shortcut for Ack
let g:ackprg = 'ag --nogroup --nocolor --column --vimgrep'
map <leader>/ :Ack 

" Git Commit Message
autocmd Filetype gitcommit setlocal spell textwidth=72
autocmd BufNewFile,BufRead *.md setlocal spell textwidth=120
autocmd BufNewFile,BufRead *.txt* set spell

nnoremap <leader>r <cmd>Telescope buffers<cr>
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
" map <leader>r :CtrlPBuffer<cr>
map <leader>[ :bnext<cr>
map <leader>] :bprevious<cr>
" map :bc <Plug>Kwbd

" Smart Tab mapping that preserves indentation functionality
inoremap <expr><Tab> CheckBackspace() ? "\<Tab>" : "\<C-n>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction

" Use Tab to navigate down in popup menu
inoremap <expr><Tab> pumvisible() ? "\<Down>" : CheckBackspace() ? "\<Tab>" : "\<C-n>"
" Use Shift+Tab to navigate up in popup menu
inoremap <expr><S-Tab> pumvisible() ? "\<Up>" : "\<S-Tab>"

" Console vim uses system clipboard
set clipboard=unnamed

" highlight long lines
au FileType ruby,haml let w:m2=matchadd('ErrorMsg', '\%>120v.\+', -1)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RENAME CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <leader>n :call RenameFile()<cr>

syntax on
filetype plugin indent on

autocmd BufWritePre *.rb,*.haml,*.rake,*.erb,*.css,*.sass,*.scss,*.js,*.coffee,*.god,*.inky,*.ts :%s/\s\+$//e

call neomake#configure#automake('w')

" Run each enabled maker one after the other.
let g:neomake_serialize = 1

" Abort after the first error status is encountered
let g:neomake_serialize_abort_on_error = 1

" Preseve cursor position when quickfix window is open
" let g:neomake_open_list = 2

" The height of quickfix list opened by Neomake
let g:neomake_list_height = 10

let g:neomake_ruby_enabled_makers = ['rubocop']
let g:neomake_ruby_rubocop_exe = 'bin/rubocop'

let g:neomake_javascript_eslint_exe = nrun#Which('eslint')
let g:neomake_javascript_enabled_makers = ['eslint']

" Use ag for GSearch
"
set grepprg=ag

let g:grep_cmd_opts = '--line-numbers --noheading'

" Runing tests
"
nmap <silent> t<C-n> :TestNearest<CR> " t Ctrl+n
nmap <silent> t<C-f> :TestFile<CR>    " t Ctrl+f
nmap <silent> t<C-s> :TestSuite<CR>   " t Ctrl+s
nmap <silent> t<C-l> :TestLast<CR>    " t Ctrl+l
nmap <silent> t<C-g> :TestVisit<CR>   " t Ctrl+g

let test#strategy = "neovim"

" autocmd BufNewFile,BufRead /path/to/code* let test#project_root = "/project-root"

" stop checking HTML files
let g:syntastic_html_checkers=['']

lua << EOF
EOF

" nnoremap <leader>ce <cmd>CopilotChatExplain<cr>
" nnoremap <leader>ct <cmd>CopilotChatTests<cr>
" xnoremap <leader>cv :CopilotChatVisual<cr>
" xnoremap <leader>cx :CopilotChatInPlace<cr>
