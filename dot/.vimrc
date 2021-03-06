filetype on

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'Lokaltog/vim-easymotion'
Plugin 'airblade/vim-gitgutter'
Plugin 'altercation/vim-colors-solarized'
Plugin 'blarghmatey/split-expander'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'corpix/cello.vim'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'derekwyatt/vim-scala'
Plugin 'dkprice/vim-easygrep'
Plugin 'gmarik/Vundle.vim'
Plugin 'kana/vim-textobj-user'
Plugin 'kchmck/vim-coffee-script'
Plugin 'kien/ctrlp.vim'
Plugin 'jgdavey/tslime.vim'
Plugin 'myusuf3/numbers.vim'
Plugin 'nelstrom/vim-textobj-rubyblock'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'plasticboy/vim-markdown'
Plugin 'rking/ag.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/syntastic'
Plugin 'sjl/vitality.vim'
Plugin 'slim-template/vim-slim'
Plugin 'takac/vim-hardtime'
Plugin 'thoughtbot/vim-rspec'
Plugin 'tmhedberg/matchit'
Plugin 'tomtom/tlib_vim'
Plugin 'tpope/vim-bundler'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-fugitive'
Plugin 'fatih/vim-go'
Plugin 'tpope/vim-haml'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-surround'
Plugin 'vim-ruby/vim-ruby'
Plugin 'vim-scripts/tComment'
Plugin 'wting/rust.vim'
Plugin 'justinmk/vim-syntax-extra'
Plugin 'python-mode/python-mode'

call vundle#end()
filetype plugin indent on

syntax enable
highlight ExtraWhitespace ctermbg = black
set list listchars=tab:»·,trail:·
"set list listchars=tab:▶·,trail:·
let g:solarized_termcolors=256
let g:solarized_termtrans=1
let g:solarized_degrade=0
let g:solarized_visibility="normal"
set background=dark
colorscheme solarized

set laststatus=2
let g:airline#extensions#tabline#enabled=1

set directory=$HOME/.vim/swapfiles//

let g:syntastic_ruby_checkers  = ['mri']
let g:syntastic_enable_highlighting=0

" Maybe fix slim
autocmd FileType slim setlocal foldmethod=indent
autocmd BufNewFile,BufRead *.slim set filetype=slim

" Fix rust
autocmd FileType rust setlocal shiftwidth=2 tabstop=2

" Fix mutt
"autocmd FileType mail setlocal fo+=aw
autocmd FileType mail set spell
autocmd FileType mail set textwidth=76

" Fix coffee
autocmd BufNewFile,BufRead *.coffee set filetype=coffee

" Easier split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Easier window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Remap colon to semicolon
nnoremap ; :

" Split below and right
set splitbelow
set splitright

" Persistent undo
set undodir=~/.vim/undo/
set undofile
set undolevels=1000
set undoreload=10000

" Numbers
set number
set numberwidth=3

" Case stuff
set smartcase
set ignorecase
set noantialias

set nocompatible
set backspace=2
set nobackup
set ruler
set showcmd

" Search
set incsearch
set hlsearch
set autowrite

" Highlight characters over 80 col
highlight LineTooLong ctermbg=darkgray ctermfg=black
call matchadd('LineTooLong', '\%81v', 100)
                                                                                                                                                                 "
" Leader
let mapleader = " "
" Toggle nerdtree with F10
map <F10> :NERDTreeToggle<CR>

" Current file in nerdtree
map <F9> :NERDTreeFind<CR>

" Reduce timeout after <ESC> is recvd. This is only a good idea on fast links.
set ttimeout
set ttimeoutlen=20
set notimeout

" Enable rainbow parens
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

" Edit another file in the same directory as the current file
" uses expression to extract path from current file's path
map <Leader>e :e <C-R>=expand("%:p:h") . '/'<CR>
map <Leader>s :split <C-R>=expand("%:p:h") . '/'<CR>
map <Leader>v :vnew <C-R>=expand("%:p:h") . '/'<CR>

" highlight vertical column of cursor
au WinLeave * set nocursorline nocursorcolumn
au WinEnter * set cursorline
set cursorline

"key to insert mode with paste using F2 key
map <F2> :set paste<CR>i
" Leave paste mode on exit
au InsertLeave * set nopaste

" Command aliases
cabbrev tp tabprev
cabbrev tn tabnext
cabbrev tf tabfirst
cabbrev tl tablast

" Fuzzy finder: ignore stuff that can't be opened, and generated files
let g:fuzzy_ignore = "*.png;*.PNG;*.JPG;*.jpg;*.GIF;*.gif;vendor/**;coverage/**;tmp/**;rdoc/**"

" Cursor highlight
hi CursorLineNr guifg=#050505

" Airline
let g:airline_theme='solarized'
set t_Co=256

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup
  let g:grep_cmd_opts = '--line-numbers --noheading'

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" bind K to search word under cursor
nnoremap K :Ag "\b<C-R><C-W>\b"<CR>:cw<CR>

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set expandtab

let g:rspec_command = 'call Send_to_Tmux("bundle exec rspec {spec}\n")'
let g:rspec_runner = "os_x_iterm"

" RSpec.vim mappings
map <Leader>t :call RunCurrentSpecFile()<CR>
map <Leader>s :call RunNearestSpec()<CR>
map <Leader>l :call RunLastSpec()<CR>
map <Leader>a :call RunAllSpecs()<CR>

autocmd BufRead,BufNewFile *.rs set filetype=rust

" N3RDTreeIgnore
let NERDTreeIgnore = ['\.pyc$','\.class$','\.o$']
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.class,*.d,*.o
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn|class|o|d)$'
"let g:ctrlp_working_path_mode = 'rw'
autocmd BufRead,BufNewFile *.c,*.h set noexpandtab filetype=c.doxygen tabstop=4 softtabstop=4 shiftwidth=4

" Custom Notes filetype
au BufNewFile,BufRead *.kek set filetype=notes
autocmd FileType notes set tw=79
autocmd FileType notes set spelllang=en
autocmd FileType notes set spell!
