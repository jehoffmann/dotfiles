" Autoinstall vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
call plug#begin('~/.vim/bundle')

Plug 'bling/vim-airline' |Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'
Plug 'ntpeters/vim-better-whitespace'

Plug 'jeffkreeftmeijer/vim-numbertoggle'

Plug 'ekalinin/Dockerfile.vim', { 'for' : 'Dockerfile' }

" Initialize plugin system
call plug#end()

:set number relativenumber

" Airline config
let g:airline_theme='dark'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tmuxline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

let g:tmuxline_powerline_separators = 0

" Better whitespace config
let g:show_spaces_that_precede_tabs=1

set background=dark

"Always show current position
set ruler

" Show ruler at 80 and 120
set colorcolumn=80,120
highlight clear SignColumn
highlight ColorColumn ctermbg=LightGray

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
