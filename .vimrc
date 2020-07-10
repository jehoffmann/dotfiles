" Autoinstall vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
call plug#begin('~/.vim/bundle')

Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'
Plug 'ntpeters/vim-better-whitespace'

Plug 'jeffkreeftmeijer/vim-numbertoggle'

Plug 'terryma/vim-multiple-cursors'

Plug 'kien/rainbow_parentheses.vim'
Plug 'nathanaelkane/vim-indent-guides'

Plug 'scrooloose/syntastic'
Plug 'tpope/vim-surround'

Plug 'ekalinin/Dockerfile.vim', { 'on' : 'Dockerfile' }

Plug 'vhdirk/vim-cmake'
Plug 'vim-scripts/c.vim', { 'on' : 'C' }

Plug 'tfnico/vim-gradle'
Plug 'mikelue/vim-maven-plugin'

Plug 'rust-lang/rust.vim', { 'on' : 'Rust' }

Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-bundler'
Plug 'thoughtbot/vim-rspec'

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

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" C Plugin
let g:C_UseTool_cmake   = 'yes'
let g:C_UseTool_doxygen = 'yes'

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

au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1

" Configure backspace so it acts as it should act
set backspace=eol,start,indent

set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.

set shiftwidth=4    " Indents will have a width of 4

set softtabstop=4   " Sets the number of columns for a TAB

set expandtab       " Expand TABs to spaces

set rtp+=/usr/local/opt/fzf
