" ══════════════════════════════════════════════════════════════════════════════
" Runtimes (mise)
" ══════════════════════════════════════════════════════════════════════════════

" mise-Shims vorn in den PATH: Vim und alle Plugins/Language-Server nutzen die
" Runtimes aus ~/.config/mise/config.toml – auch wenn Vim nicht aus einer
" aktivierten Shell gestartet wurde. Plugins installieren keine eigenen Binaries.
let s:mise_shims = (empty($XDG_DATA_HOME) ? $HOME . '/.local/share' : $XDG_DATA_HOME) . '/mise/shims'
if isdirectory(s:mise_shims) && stridx($PATH, s:mise_shims) < 0
  let $PATH = s:mise_shims . ':' . $PATH
endif

" coc: Settings unter ~/.config/coc (XDG), Language-Server aus dem PATH
let g:coc_config_home = (empty($XDG_CONFIG_HOME) ? $HOME . '/.config' : $XDG_CONFIG_HOME) . '/coc'

" Capabilities – heavy IDE plugins only where they can run (servers, Ubuntu 20.04's Vim 8.1)
let s:has_coc        = executable('node') && (has('nvim-0.8') || has('patch-9.0.0438'))
let s:has_vimspector = has('python3') && (has('nvim-0.8') || has('patch-8.2.4797'))
let s:has_ctags      = executable('ctags')


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
Plug 'dracula/vim', { 'as': 'dracula' }   " Fallback ohne Dracula PRO
Plug 'ryanoasis/vim-devicons'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'kien/rainbow_parentheses.vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'jeffkreeftmeijer/vim-numbertoggle'

" ── Navigation & Search ──────────────────────────────────────────────────────
Plug 'junegunn/fzf'                       " base Vim integration, uses fzf from PATH
Plug 'junegunn/fzf.vim'
Plug 'christoomey/vim-tmux-navigator'
if s:has_ctags
  Plug 'ludovicchabant/vim-gutentags'     " auto ctags/cscope for large trees
endif

" ── Editing ──────────────────────────────────────────────────────────────────
Plug 'tpope/vim-surround'
Plug 'mg979/vim-visual-multi'

" ── LSP / Intellisense (IDE core) ────────────────────────────────────────────
if s:has_coc
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif

" ── Debugging ────────────────────────────────────────────────────────────────
if s:has_vimspector
  Plug 'puremourning/vimspector'
endif

" ── Git ──────────────────────────────────────────────────────────────────────
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

" ── Build / Dispatch ─────────────────────────────────────────────────────────
Plug 'tpope/vim-dispatch'

" Sprach-Plugins laden nur für ihren Filetype ('for'); Tooling (gopls,
" rust-analyzer, ruff, clangd …) kommt aus mise/PATH, nicht aus den Plugins.
Plug 'jpalardy/vim-slime'

" ── C / C++ / Embedded / Kernel ─────────────────────────────────────────────
Plug 'vim-scripts/c.vim',                 { 'for': ['c', 'cpp'] }
Plug 'bfrg/vim-cpp-modern',               { 'for': ['c', 'cpp'] }
Plug 'rhysd/vim-clang-format',            { 'for': ['c', 'cpp'] }
Plug 'vivien/vim-linux-coding-style',     { 'for': ['c', 'cpp'] }  " kernel style per tree

" ── Android / AOSP ──────────────────────────────────────────────────────────
Plug 'udalov/kotlin-vim',                 { 'for': 'kotlin' }
Plug 'cappyzawa/starlark.vim',            { 'for': 'starlark' }   " Android.bp / BUILD

" ── Go ───────────────────────────────────────────────────────────────────────
" Kein :GoUpdateBinaries – das würde gopls & Co. nach $GOPATH/bin bauen
if executable('go') && (has('nvim-0.4') || has('patch-8.2.5072'))   " vim-go minimum, only with Go installed
  Plug 'fatih/vim-go',                    { 'for': 'go' }
endif

" ── Rust ─────────────────────────────────────────────────────────────────────
Plug 'rust-lang/rust.vim',                { 'for': 'rust' }

" ── Python ───────────────────────────────────────────────────────────────────
" black/flake8-Plugins entfernt (legten eigene venvs an) → ruff via coc

" ── Ruby ─────────────────────────────────────────────────────────────────────
Plug 'vim-ruby/vim-ruby',                 { 'for': 'ruby' }
Plug 'tpope/vim-bundler',                 { 'for': 'ruby' }
Plug 'thoughtbot/vim-rspec',              { 'for': 'ruby' }

" ── Shell / Scripting ────────────────────────────────────────────────────────
Plug 'WolfgangMehner/bash-support', { 'for': 'sh' }
Plug 'zsh-users/zsh-syntax-highlighting', { 'for': 'zsh' }
Plug 'ekalinin/Dockerfile.vim', { 'for': 'dockerfile' }

" ── Build Systems ────────────────────────────────────────────────────────────
Plug 'vhdirk/vim-cmake', { 'for': 'cmake' }
Plug 'tfnico/vim-gradle', { 'for': 'gradle' }
Plug 'mikelue/vim-maven-plugin', { 'for': 'maven' }

" ── Testing ──────────────────────────────────────────────────────────────────
Plug 'alepez/vim-gtest',                 { 'for': 'cpp' }
Plug 'alfredodeza/pytest.vim',            { 'for': 'python' }

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
set termguicolors    " enable true color (tmux: terminal-features RGB)

" Theme: Dracula PRO, wenn lokal installiert (lizenziert, nicht im Repo), sonst freies Dracula
let s:dracula_pro = (empty($XDG_DATA_HOME) ? $HOME . '/.local/share' : $XDG_DATA_HOME) . '/dracula-pro/themes/vim'
if isdirectory(s:dracula_pro)
  execute 'set runtimepath+=' . fnameescape(s:dracula_pro)
  let g:dracula_colorterm = 0
  silent! colorscheme dracula-pro
  let g:airline_theme = 'dracula-pro'
else
  silent! colorscheme dracula
  let g:airline_theme = 'dracula'
endif

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab


" ══════════════════════════════════════════════════════════════════════════════
" UI / Appearance
" ══════════════════════════════════════════════════════════════════════════════

highlight clear SignColumn

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

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#parts#ffenc#skip_expected_string = 'utf-8[unix]'
" tmux statusbar is managed by dracula/tmux, not tmuxline


" ══════════════════════════════════════════════════════════════════════════════
" File Explorer  (coc-explorer)
" ══════════════════════════════════════════════════════════════════════════════

if s:has_coc
  nnoremap <C-n>      :CocCommand explorer<CR>
  nnoremap <leader>nf :CocCommand explorer --reveal<CR>
else
  nnoremap <C-n>      :Lexplore<CR>
endif


" ══════════════════════════════════════════════════════════════════════════════
" FZF / Project Search
" ══════════════════════════════════════════════════════════════════════════════

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

if s:has_coc

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

endif


" ══════════════════════════════════════════════════════════════════════════════
" C / C++ / Embedded
" ══════════════════════════════════════════════════════════════════════════════

let g:C_UseTool_cmake   = 'yes'
let g:C_UseTool_doxygen = 'yes'

" Skip auto-format in kernel/AOSP trees — they have per-module style configs
function! ClangFormatIfNotKernel() abort
  if expand('%:p') =~# '\v/(linux|kernel|aosp)/' || !executable('clang-format') || !exists(':ClangFormat')
    return
  endif
  ClangFormat
endfunction
autocmd BufWritePre *.c,*.cpp,*.h,*.hpp call ClangFormatIfNotKernel()


" ══════════════════════════════════════════════════════════════════════════════
" Go
" ══════════════════════════════════════════════════════════════════════════════

" Delegate navigation, docs, formatting to coc-go/gopls; vim-go provides extras only
let g:go_def_mapping_enabled    = 0
let g:go_doc_keywordprg_enabled = 0
let g:go_gopls_enabled          = 0   " gopls läuft über coc, nicht doppelt
let g:go_fmt_autosave           = 0   " Format on save macht coc (coc-settings.json)
let g:go_get_update             = 0   " keine Tool-Updates durch vim-go
let g:go_imports_autosave      = 0   " goimports on save: coc/gopls handles imports

autocmd FileType go nmap <buffer> <leader>gt :GoTest<CR>
autocmd FileType go nmap <buffer> <leader>gr :GoRun<CR>


" ══════════════════════════════════════════════════════════════════════════════
" Rust
" ══════════════════════════════════════════════════════════════════════════════

" Format on save über coc/rust-analyzer (rustfmt aus der mise-Toolchain)
let g:rustfmt_autosave = 0

augroup rust_maps
  au!
  au FileType rust setlocal tabstop=4 shiftwidth=4 expandtab
  au FileType rust nnoremap <buffer> <Leader>rr :Dispatch cargo run<CR>
  au FileType rust nnoremap <buffer> <Leader>rt :Dispatch cargo test<CR>
  au FileType rust nnoremap <buffer> <Leader>rb :Dispatch cargo build<CR>
  au FileType rust nnoremap <buffer> <Leader>rc :Dispatch cargo check<CR>
augroup END


" ══════════════════════════════════════════════════════════════════════════════
" Python
" ══════════════════════════════════════════════════════════════════════════════

" Format + Lint: ruff (mise) als Language-Server über coc, Format on save in coc-settings.json


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
