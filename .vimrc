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
Plug 'ludovicchabant/vim-gutentags'       " auto ctags/cscope for large trees

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

" ── C / C++ / Embedded / Kernel ─────────────────────────────────────────────
Plug 'vim-scripts/c.vim'
Plug 'bfrg/vim-cpp-modern'
Plug 'rhysd/vim-clang-format'
Plug 'jpalardy/vim-slime'
Plug 'vivien/vim-linux-coding-style'      " kernel style (tabs, 8-width) per tree

" ── Android / AOSP ──────────────────────────────────────────────────────────
Plug 'udalov/kotlin-vim'                  " Kotlin syntax highlighting
Plug 'cappyzawa/starlark.vim'             " Android.bp / BUILD syntax

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
set mouse=a
set ttimeoutlen=10   " match tmux escape-time; prevents ESC lag in insert mode
set termguicolors    " enable true color (requires tmux terminal-overrides Tc)

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
let g:airline#parts#ffenc#skip_expected_string = 'utf-8[unix]'
" tmux statusbar is managed by tmux-themepack, not tmuxline


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
      \ 'coc-java', 'coc-kotlin', 'coc-sh',
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

" Skip auto-format in kernel/AOSP trees — they have per-module style configs
function! ClangFormatIfNotKernel() abort
  if expand('%:p') =~# '\v/(linux|kernel|aosp)/'
    return
  endif
  ClangFormat
endfunction
autocmd BufWritePre *.c,*.cpp,*.h,*.hpp call ClangFormatIfNotKernel()


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


" ══════════════════════════════════════════════════════════════════════════════
" Linux Kernel Development
" ══════════════════════════════════════════════════════════════════════════════

" vim-linux-coding-style auto-applies kernel style (8-space tabs, no expandtab)
" when a file is inside a kernel tree (detected by Kconfig/MAINTAINERS).
" Override patterns if your tree lives under a non-standard path.
let g:linuxsty_patterns = [ '/linux', '/kernel', '/aosp' ]

" cscope — cross-reference navigation across macro boundaries
" (clangd alone can't resolve DEFINE_PER_CPU and similar macro-heavy symbols)
if has('cscope')
  set cscopetag     " use cscope for Ctrl+] and :tag
  set csto=0        " search cscope before ctags

  if filereadable('cscope.out')
    silent cs add cscope.out
  elseif !empty($CSCOPE_DB)
    silent cs add $CSCOPE_DB
  endif

  " s: find symbol    c: find callers    i: find #includes    t: find text
  nmap <leader>ks :cs find s <C-R>=expand('<cword>')<CR><CR>
  nmap <leader>kc :cs find c <C-R>=expand('<cword>')<CR><CR>
  nmap <leader>ki :cs find i <C-R>=expand('<cfile>')<CR><CR>
  nmap <leader>kt :cs find t <C-R>=expand('<cword>')<CR><CR>
endif

" Kernel build dispatch  (set ARCH/CROSS_COMPILE per project in .vimspector.json)
nnoremap <leader>km :Dispatch make -j$(nproc)<CR>
nnoremap <leader>kM :Dispatch make -j$(nproc) modules<CR>


" ══════════════════════════════════════════════════════════════════════════════
" Android / AOSP
" ══════════════════════════════════════════════════════════════════════════════

" Filetype mappings for AOSP-specific file formats
augroup aosp_filetypes
  au!
  " Android.bp uses Starlark (Python superset) — handled by vim-starlark
  au BufRead,BufNewFile Android.bp   setfiletype starlark
  " Android.mk is standard Makefile syntax
  au BufRead,BufNewFile Android.mk   setfiletype make
  " AIDL and HIDL use Java/C-like syntax
  au BufRead,BufNewFile *.aidl       setfiletype java
  au BufRead,BufNewFile *.hal        setfiletype c
augroup END

" clang-format is suppressed for AOSP/kernel paths by ClangFormatIfNotKernel()
" Place a .clang-format file in individual AOSP module roots as needed.


" ══════════════════════════════════════════════════════════════════════════════
" Large Codebase Navigation  (gutentags)
" ══════════════════════════════════════════════════════════════════════════════

" gutentags rebuilds ctags/cscope incrementally in the background.
" Essential for kernel and AOSP trees where clangd symbol search is slow.
let g:gutentags_modules            = ['ctags', 'cscope']
let g:gutentags_project_root       = ['.git', 'Makefile', 'CMakeLists.txt', 'Android.bp', 'Kconfig']
let g:gutentags_cache_dir          = expand('~/.cache/gutentags')
let g:gutentags_generate_on_new    = 1
let g:gutentags_generate_on_missing = 1
let g:gutentags_generate_on_write  = 1
" Exclude generated output dirs common in kernel/AOSP builds
let g:gutentags_ctags_exclude      = ['out', '.repo', '*.json', '*.xml', 'Documentation']
