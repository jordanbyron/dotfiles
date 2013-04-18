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

" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
" set t_ti= t_te=

syntax on
filetype plugin indent on

autocmd FileType make setlocal noexpandtab shiftwidth=8
au BufWrite /private/tmp/crontab.* set nowritebackup
au BufWrite /private/tmp/crontab.* set nobackup

au FileType ruby,eruby set omnifunc=rubycomplete#Complete
au FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
au FileType ruby,eruby let g:rubycomplete_rails = 1
au FileType ruby,eruby let g:rubycomplete_classes_in_global = 2
au FileType ruby,eruby noremap <C-r> :!ruby %<CR>

" Other completions
au FileType python set omnifunc=pythoncomplete#Complete
au FileType javascript set omnifunc=javascriptcomplete#CompleteJS
au FileType html set omnifunc=htmlcomplete#CompleteTags
au FileType css set omnifunc=csscomplete#CompleteCSS
au FileType xml set omnifunc=xmlcomplete#CompleteTags
au FileType php set omnifunc=phpcomplete#CompletePHP
au FileType c set omnifunc=ccomplete#Complete

" TODO fix ftdetect with pathogen
au! BufRead,BufNewFile *.otl		setfiletype vo_base

au! BufRead,BufNewFile Vagrantfile set ft=ruby
au! BufRead,BufNewFile Guardfile set ft=ruby

" highlight long lines
"au FileType ruby let w:m1=matchadd('Search', '\%<81v.\%>77v', -1)
au FileType ruby,haml let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)

let mapleader = ","

" NERD_Tree
map <leader>d :execute 'NERDTreeToggle ' . getcwd()<CR>

" Shortcut for Ack
map <leader>/ :Ack 

" ,e => :edit in current directory
" cnoremap %% <C-R>=expand('%:h').'/'<cr>
" map <leader>e :edit %%

imap <C-l> <space>=><space>

colorscheme xoria256

" Console vim uses system clipboard
set clipboard=unnamed

""" XXX Be friendlier to laptop-mode (dangerous) XXX
set swapsync=
set nofsync

" easier split navigation
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
imap <C-l> <space>=><space>

" pull up tags
noremap <Leader>m :CommandTTag<cr>
let g:CommandTTagIncludeFilenames=1

" ignore some stuff from Command-T
set wildignore+=.git
" Binary
set wildignore+=*.o,*.class,*.jar,*.png,*.jpg
" Shapefiles
set wildignore+=*.prj,*.shp,*.shx,*.cpg,*.dbf
" Ruby project artifacts
set wildignore+=vendor/bundle/*,vendor/cache/*,*.gem,tmp/sass-cache/*
" typical binary/image/etc locations
set wildignore+=public/system/*

""" Terminal stuff

" http://stackoverflow.com/questions/2158516/vim-delay-before-o-opens-a-new-line
" http://robots.thoughtbot.com/post/2166174647/love-hate-tmux
"set notimeout
"set ttimeout
"set timeoutlen=50

" Time out after 1 second for mappings (e.g., gc or ,t); 50ms for key codes
" such as esc (figure the terminal will be fast enough).
set timeoutlen=1000
set ttimeoutlen=50
set ttyfast

" https://wincent.com/forums/command-t/topics/430
let g:CommandTSelectPrevMap=['<C-p>', '<C-k>', '<Esc>OA', '<Up>']
let g:CommandTSelectNextMap=['<C-n>', '<C-j>', '<Esc>OB', '<Down>']
let g:CommandTCancelMap=['<ESC>','<C-c>']

" https://github.com/wincent/Command-T/pull/50
let g:CommandTUseMruBufferOrder=1

" http://vim.wikia.com/wiki/Keep_folds_closed_while_inserting_text
" Don't screw up folds when inserting text that might affect them, until
" leaving insert mode. Foldmethod is local to the window. Protect against
" screwing up folding when switching between windows.
autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
set foldmethod=syntax
" fix slowness http://github.com/vim-ruby/vim-ruby/issues/closed/#issue/8
" set foldmethod=manual
set foldlevelstart=99

" Run the current file with rspec
function MapRubyKeys()
  map <Leader>rb :call RunVimTmuxCommand("clear; rspec " . bufname("%"))<CR>
  map <Leader>ri :InspectVimTmuxRunner<CR>
  map <Leader>rx :CloseVimTmuxPanes()<CR>
  map <Leader>rr :RunAllRubyTests<CR>
  map <Leader>rt :RunRubyFocusedTest<CR>
  map <Leader>rc :RunRubyFocusedContext<CR>
endfunction
autocmd FileType ruby call MapRubyKeys()
let g:VimuxUseNearestPane = 1

""" bufsurf
map <Leader>gh :BufSurfBack<CR>
map <Leader>gl :BufSurfForward<CR>

""" MacVIM GUI options
if has("gui_running")
  " hide toolbar
  set guioptions-=T
  
  set visualbell t_vb=

  set guifont=Inconsolata:h18

  " set to nice size
  set lines=50 columns=90
endif

""" VimClojure
let g:paredit_matchlines=1000
let vimclojure#FuzzyIndent=1
let vimclojure#HighlightBuiltins=1
let vimclojure#HighlightContrib=1
let vimclojure#DynamicHighlighting=1
let vimclojure#ParenRainbow=1
let vimclojure#WantNailgun = 1
let vimclojure#NailgunClient = $HOME . "/.vim/lib/vimclojure/nailgun-client/ng"
autocmd BufReadPre,BufNewFile *.clj let maplocalleader = ","
set nojoinspaces " J doesn't add spaces

autocmd FileType clojure setlocal lispwords+=describe,context,it

autocmd FileType c,cpp,java,ruby,clojure autocmd BufWritePre <buffer> :%s/\s\+$//e

""" More context for paredit. This limits the length (in lines) of the longest form.
let g:paredit_matchlines = 1000

" vim-powerline
set encoding=utf-8
set laststatus=2
"let g:Powerline_symbols = 'compatible'
let g:Powerline_symbols = 'fancy'

" Jordan's Stuff 

map <leader>r :CtrlPBuffer<cr>
map <leader>[ :BufSurfBack<cr>
map <leader>] :BufSurfForward<cr>
map :bc <Plug>Kwbd
