" ══════════════════════════════════════════════════════════════════════════════
" Plugin Manager
" ══════════════════════════════════════════════════════════════════════════════

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')

" ── UI & Editor ──────────────────────────────────────────────────────────────
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'kien/rainbow_parentheses.vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'jeffkreeftmeijer/vim-numbertoggle'

" ── Navigation & Search ──────────────────────────────────────────────────────
Plug 'junegunn/fzf.vim'
Plug 'christoomey/vim-tmux-navigator'

" ── Editing ──────────────────────────────────────────────────────────────────
Plug 'tpope/vim-surround'
Plug 'mg979/vim-visual-multi'

" ── LSP / Intellisense (IDE core) ────────────────────────────────────────────
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" ── Debugging ────────────────────────────────────────────────────────────────
Plug 'puremourning/vimspector'

" ── Git ──────────────────────────────────────────────────────────────────────
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

" ── Build / Dispatch ─────────────────────────────────────────────────────────
Plug 'tpope/vim-dispatch'

" ── C / C++ / Embedded ───────────────────────────────────────────────────────
Plug 'vim-scripts/c.vim'
Plug 'bfrg/vim-cpp-modern'
Plug 'rhysd/vim-clang-format'
Plug 'jpalardy/vim-slime'

" ── Go ───────────────────────────────────────────────────────────────────────
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries', 'for': 'go' }

" ── Rust ─────────────────────────────────────────────────────────────────────
Plug 'rust-lang/rust.vim'

" ── Python ───────────────────────────────────────────────────────────────────
Plug 'psf/black'
Plug 'nvie/vim-flake8'

" ── Ruby ─────────────────────────────────────────────────────────────────────
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
Plug 'tpope/vim-bundler'
Plug 'thoughtbot/vim-rspec'

" ── Shell / Scripting ────────────────────────────────────────────────────────
Plug 'WolfgangMehner/bash-support', { 'for': 'sh' }
Plug 'zsh-users/zsh-syntax-highlighting', { 'for': 'zsh' }
Plug 'ekalinin/Dockerfile.vim', { 'for': 'dockerfile' }

" ── Build Systems ────────────────────────────────────────────────────────────
Plug 'vhdirk/vim-cmake', { 'for': 'cmake' }
Plug 'tfnico/vim-gradle', { 'for': 'gradle' }
Plug 'mikelue/vim-maven-plugin', { 'for': 'maven' }

" ── Testing ──────────────────────────────────────────────────────────────────
Plug 'alepez/vim-gtest'
Plug 'alfredodeza/pytest.vim'

" ── macOS ────────────────────────────────────────────────────────────────────
if has('mac')
  Plug 'rizzatti/dash.vim'
endif

call plug#end()


" ══════════════════════════════════════════════════════════════════════════════
" General Settings
" ══════════════════════════════════════════════════════════════════════════════

set number relativenumber
set ruler
set background=dark
set backspace=eol,start,indent
set colorcolumn=80,120

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab


" ══════════════════════════════════════════════════════════════════════════════
" UI / Appearance
" ══════════════════════════════════════════════════════════════════════════════

highlight clear SignColumn
highlight ColorColumn ctermbg=LightGray

hi CursorLine cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
nnoremap <Leader>c :set cursorline!<CR>
augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END

au VimEnter * RainbowParenthesesToggle
au Syntax   * RainbowParenthesesLoadRound
au Syntax   * RainbowParenthesesLoadSquare
au Syntax   * RainbowParenthesesLoadBraces

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1
let g:show_spaces_that_precede_tabs = 1

let g:airline_theme = 'dark'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tmuxline#enabled = 1
let g:airline#parts#ffenc#skip_expected_string = 'utf-8[unix]'
let g:tmuxline_powerline_separators = 0


" ══════════════════════════════════════════════════════════════════════════════
" File Explorer  (coc-explorer)
" ══════════════════════════════════════════════════════════════════════════════

nnoremap <C-n>      :CocCommand explorer<CR>
nnoremap <leader>nf :CocCommand explorer --reveal<CR>


" ══════════════════════════════════════════════════════════════════════════════
" FZF / Project Search
" ══════════════════════════════════════════════════════════════════════════════

if !empty($HOMEBREW_PREFIX)
  set rtp+=$HOMEBREW_PREFIX/opt/fzf
elseif isdirectory($HOME . '/.fzf')
  set rtp+=~/.fzf
endif

let g:fzf_preview_window = ['right:50%', 'ctrl-/']

nnoremap <C-p>      :Files<CR>
nnoremap <leader>/  :Rg<CR>
nnoremap <leader>b  :Buffers<CR>

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)


" ══════════════════════════════════════════════════════════════════════════════
" CoC / LSP
" ══════════════════════════════════════════════════════════════════════════════

let g:coc_global_extensions = [
      \ 'coc-clangd', 'coc-pyright', 'coc-rust-analyzer', 'coc-go',
      \ 'coc-json', 'coc-yaml', 'coc-html', 'coc-xml',
      \ 'coc-java', 'coc-sh',
      \ 'coc-explorer'
      \ ]

" Tab completion
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Navigation  (like Ctrl+B / Ctrl+Alt+B)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Hover docs  (like Ctrl+Q)
nnoremap <silent> K :call CocActionAsync('doHover')<CR>

" Rename symbol  (like Shift+F6)
nmap <leader>rn <Plug>(coc-rename)

" Code action / quick fix  (like Alt+Enter)
nmap  <leader>. <Plug>(coc-codeaction-cursor)
xmap  <leader>. <Plug>(coc-codeaction-selected)

" Diagnostics navigation  (like F2 / Shift+F2)
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nnoremap <silent> <leader>d :CocList diagnostics<CR>

" Symbol search  (like Ctrl+Alt+Shift+N)
nnoremap <leader>s :CocList symbols<CR>

" Format buffer  (like Ctrl+Alt+L)
nnoremap <leader>f :call CocAction('format')<CR>


" ══════════════════════════════════════════════════════════════════════════════
" C / C++ / Embedded
" ══════════════════════════════════════════════════════════════════════════════

let g:C_UseTool_cmake   = 'yes'
let g:C_UseTool_doxygen = 'yes'

autocmd BufWritePre *.c,*.cpp,*.h,*.hpp ClangFormat


" ══════════════════════════════════════════════════════════════════════════════
" Go
" ══════════════════════════════════════════════════════════════════════════════

" Delegate navigation and docs to coc-go/gopls; vim-go provides extras only
let g:go_def_mapping_enabled    = 0
let g:go_doc_keywordprg_enabled = 0

autocmd FileType go nmap <leader>gt :GoTest<CR>
autocmd FileType go nmap <leader>gr :GoRun<CR>


" ══════════════════════════════════════════════════════════════════════════════
" Rust
" ══════════════════════════════════════════════════════════════════════════════

let g:rustfmt_autosave = 1

autocmd FileType rust setlocal tabstop=4 shiftwidth=4 expandtab
autocmd BufWritePre *.rs :RustFmt

nnoremap <Leader>rr :Dispatch cargo run<CR>
nnoremap <Leader>rt :Dispatch cargo test<CR>
nnoremap <Leader>rb :Dispatch cargo build<CR>
nnoremap <Leader>rc :Dispatch cargo check<CR>


" ══════════════════════════════════════════════════════════════════════════════
" Python
" ══════════════════════════════════════════════════════════════════════════════

autocmd BufWritePre *.py Black
