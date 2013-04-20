" Pathogen
call pathogen#infect()

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

""" MacVIM GUI options
if has("gui_running")
  " hide toolbar
  set guioptions-=T

  set visualbell t_vb=

  set guifont=Inconsolata:h18

  " set to nice size
  set lines=50 columns=90
endif

colorscheme twilight

let mapleader = ","

" NERD_Tree
map <leader>d :execute 'NERDTreeToggle ' . getcwd()<CR>

" Shortcut for Ack
map <leader>/ :Ack

" Spin
map <leader>s ! clear; bundle exec spin push %<esc>

map <leader>r :CtrlPBuffer<cr>
map <leader>[ :BufSurfBack<cr>
map <leader>] :BufSurfForward<cr>
map :bc <Plug>Kwbd
map <leader>cc :CtrlPClearCache<cr>

" Console vim uses system clipboard
set clipboard=unnamed

" highlight long lines
au FileType ruby,haml let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)

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

autocmd BufWritePre *.rb,*.haml,*.rake,*.erb,*.css,*.sass,*.scss,*.js,*.coffee :%s/\s\+$//e
