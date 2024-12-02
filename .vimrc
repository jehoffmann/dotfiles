" Autoinstall vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
call plug#begin('~/.vim/bundle')

" Essential plugins
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'christoomey/vim-tmux-navigator'
Plug 'ntpeters/vim-better-whitespace'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'terryma/vim-multiple-cursors'
Plug 'kien/rainbow_parentheses.vim'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'ryanoasis/vim-devicons'

Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive' " Git integration
Plug 'junegunn/gv.vim'   " Git commit browser

" Code navigation and IDE features
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dense-analysis/ale'
Plug 'junegunn/fzf.vim'
Plug 'puremourning/vimspector'
Plug 'tpope/vim-dispatch'

" File explorer
"Plug 'preservim/nerdtree'              " NERDTree plugin
"Plug 'Xuyuanp/nerdtree-git-plugin'     " Git integration for NERDTree

" Plugins for C, C++ and low-level development
Plug 'vim-scripts/c.vim'
Plug 'bfrg/vim-cpp-modern'
Plug 'rhysd/vim-clang-format'

" Rust-specific plugins
Plug 'rust-lang/rust.vim'             " Rust syntax highlighting, formatting, and more
Plug 'simrat39/rust-tools.nvim'       " Extra tools for Rust development

" Embedded/Kernel development plugins
Plug 'jpalardy/vim-slime'

" Python development plugins
Plug 'psf/black'
Plug 'nvie/vim-flake8'

" Ruby
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
Plug 'tpope/vim-bundler'
Plug 'thoughtbot/vim-rspec'

" Scripting language support
Plug 'WolfgangMehner/bash-support', { 'for': 'sh' } " Enhanced Bash scripting
Plug 'zsh-users/zsh-syntax-highlighting', { 'for': 'zsh' }

Plug 'ekalinin/Dockerfile.vim', { 'for' : 'dockerfile' }

" Build system plugins
Plug 'vhdirk/vim-cmake', { 'for': 'cmake' }
Plug 'tfnico/vim-gradle', { 'for': 'gradle' }
Plug 'mikelue/vim-maven-plugin', { 'for': 'maven' }

" Testing framework plugins
Plug 'alepez/vim-gtest'
Plug 'alfredodeza/pytest.vim'

Plug 'rizzatti/dash.vim'

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

" Enable CoC (Language Server Protocol)
let g:coc_global_extensions = [
      \ 'coc-clangd', 'coc-pyright', 'coc-json', 'coc-yaml',
      \ 'coc-html', 'coc-xml', 'coc-java', 'coc-sh',
      \ 'coc-rust-analyzer'
      \ ]

" ALE configuration
let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1

" Rust-specific configuration
autocmd FileType rust setlocal tabstop=4 shiftwidth=4 expandtab
autocmd BufWritePre *.rs :RustFmt    " Automatically format with rustfmt
let g:rustfmt_autosave = 1           " Enable autoformat on save

" Key mappings for Rust tools
nnoremap <Leader>rr :Dispatch cargo run<CR>
nnoremap <Leader>rt :Dispatch cargo test<CR>
nnoremap <Leader>rb :Dispatch cargo build<CR>
nnoremap <Leader>rc :Dispatch cargo check<CR>

" Autoformat on save
autocmd BufWritePre *.c,*.cpp,*.h,*.hpp ClangFormat
autocmd BufWritePre *.py Black

"packadd! dracula_pro
"colorscheme dracula_pro

"nnoremap <C-n> :NERDTreeToggle<CR> " File explorer toggle
"nnoremap <C-p> :CtrlP<CR>          " Fuzzy file finder

set rtp+=/usr/local/opt/fzf
