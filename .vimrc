" Vundle config
set nocompatible              " be iMproved, required
filetype off                  " required

" check if vundle is installed
if !isdirectory(expand("~/.vim/bundle/Vundle.vim/.git"))
    !git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
endif

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'bling/vim-airline'
set laststatus=2
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tmuxline#enabled = 1

Plugin 'kien/rainbow_parentheses.vim'
Plugin 'rizzatti/dash.vim'
Plugin 'majutsushi/tagbar'
Plugin 'edkolev/tmuxline.vim'
let g:tmuxline_powerline_separators = 0

" Git integration
Plugin 'tpope/vim-git'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
set background=dark
highlight clear SignColumn

" C/C++
Plugin 'c.vim'
Plugin 'cpp.vim'

" Lua
"Plugin 'lua.vim'
"Plugin 'luarefvim'
"Plugin 'lua-support'

" Python
Plugin 'python.vim'
Plugin 'pythoncomplete'

" Groovy
Plugin 'groovy.vim'
Plugin 'tfnico/vim-gradle'

" Android
Plugin 'hsanson/vim-android'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Enable filetype plugins
filetype plugin on

let g:tmuxline_powerline_separators = 0

" Set to auto read when a file is changed from the outside
set autoread

"Always show current position
set ruler

" Show ruler at 80 and 120
set colorcolumn=80,120
highlight ColorColumn ctermbg=LightGray

" Show line numbers
set number

" Highligh active line
hi CursorLine   cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white"
nnoremap <Leader>c :set cursorline! <CR>
augroup CursorLine
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END


" Configure backspace so it acts as it should act
set backspace=eol,start,indent

"  Enable syntax highlighting
syntax enable

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

function! NumberToggle()
  if(&relativenumber == 1)
    set number
  else
    set relativenumber
  endif
endfunc

nnoremap <C-n> :call NumberToggle()<cr>

