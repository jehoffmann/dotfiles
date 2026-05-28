# encoding: utf-8
cheatsheet do
  title 'Vim (Local Config)'
  docset_file_name 'Vim_Local'
  keyword 'vim'

  introduction <<-'END'
    Keybindings for ~/.vimrc (local config).
    Leader = \ (default mapleader - not overridden in config).
    Plugins managed via vim-plug. LSP via coc.nvim.
  END

  ##############################################################################
  category do
    id 'LSP / CoC - Navigation'
    entry do
      command 'gd'
      name 'Go to Definition'
      notes 'Like Ctrl+B in JetBrains. Jumps to symbol definition via clangd / rust-analyzer / gopls etc.'
    end
    entry do
      command 'gy'
      name 'Go to Type Definition'
    end
    entry do
      command 'gi'
      name 'Go to Implementation'
      notes 'Like Ctrl+Alt+B in JetBrains.'
    end
    entry do
      command 'gr'
      name 'Find References'
      notes 'Like Alt+F7 in JetBrains. Lists all usages in quickfix panel.'
    end
    entry do
      command 'K'
      name 'Hover Documentation'
      notes 'Like Ctrl+Q in JetBrains. Shows LSP hover info in floating window.'
    end
  end

  ##############################################################################
  category do
    id 'LSP / CoC - Code Intelligence'
    entry do
      command '\rn'
      name 'Rename Symbol'
      notes 'Like Shift+F6 in JetBrains. Renames across all usages.'
    end
    entry do
      command '\.'
      name 'Code Action / Quick Fix (normal mode)'
      notes 'Like Alt+Enter in JetBrains. Fix imports, generate stubs, etc.'
    end
    entry do
      command '\.'
      name 'Code Action on selection (visual mode)'
    end
    entry do
      command '\f'
      name 'Format Buffer'
      notes 'Like Ctrl+Alt+L in JetBrains. Uses LSP formatter.'
    end
    entry do
      command '\s'
      name 'Symbol Search (project-wide)'
      notes 'Like Ctrl+Alt+Shift+N in JetBrains. Opens CocList symbols.'
    end
    entry do
      command ':CocList extensions'
      name 'List installed CoC extensions'
    end
    entry do
      command ':CocInstall coc-X'
      name 'Install a CoC extension'
    end
  end

  ##############################################################################
  category do
    id 'LSP / CoC - Diagnostics'
    entry do
      command ']g'
      name 'Next Diagnostic'
      notes 'Like F2 in JetBrains.'
    end
    entry do
      command '[g'
      name 'Previous Diagnostic'
      notes 'Like Shift+F2 in JetBrains.'
    end
    entry do
      command '\d'
      name 'List all Diagnostics'
      notes 'Opens CocList diagnostics in quickfix-style panel.'
    end
  end

  ##############################################################################
  category do
    id 'LSP / CoC - Completion'
    entry do
      command 'Tab'
      name 'Next completion item (or insert literal tab if no popup)'
      notes 'Triggers completion if cursor is after a non-whitespace character.'
    end
    entry do
      command 'Shift+Tab'
      name 'Previous completion item'
    end
    entry do
      command 'Enter'
      name 'Confirm completion'
    end
  end

  ##############################################################################
  category do
    id 'File Explorer - coc-explorer'
    entry do
      command 'Ctrl+N'
      name 'Toggle File Explorer'
      notes 'Opens/closes coc-explorer sidebar. Like the Project panel in JetBrains.'
    end
    entry do
      command '\nf'
      name 'Reveal current file in Explorer'
      notes 'Equivalent to "Select in Project View" in JetBrains.'
    end
    entry do
      command ':CocCommand explorer'
      name 'Open Explorer (command form)'
    end
    entry do
      command ':CocCommand explorer --reveal'
      name 'Open Explorer and reveal current file (command form)'
    end
  end

  ##############################################################################
  category do
    id 'Search & Files - FZF + Ripgrep'
    entry do
      command 'Ctrl+P'
      name 'Find File (fzf)'
      notes 'Like Ctrl+Shift+N in JetBrains. Fuzzy search all project files.'
    end
    entry do
      command '\/'
      name 'Search text project-wide (ripgrep + preview)'
      notes 'Like Ctrl+Shift+F in JetBrains. Opens :Rg with live preview pane.'
    end
    entry do
      command '\b'
      name 'Switch Buffer (fzf)'
      notes 'Fuzzy-search through all open buffers.'
    end
    entry do
      command 'Ctrl+/'
      name 'Toggle preview window (inside fzf popup)'
    end
  end

  ##############################################################################
  category do
    id 'Rust - cargo via vim-dispatch'
    entry do
      command '\rr'
      name 'cargo run'
      notes 'Dispatched asynchronously via vim-dispatch.'
    end
    entry do
      command '\rt'
      name 'cargo test'
    end
    entry do
      command '\rb'
      name 'cargo build'
    end
    entry do
      command '\rc'
      name 'cargo check'
    end
    entry do
      command 'BufWritePre *.rs'
      name 'rustfmt on save (automatic)'
      notes 'Configured via g:rustfmt_autosave = 1. Also bound to :RustFmt.'
    end
  end

  ##############################################################################
  category do
    id 'Go - vim-go + coc-go (gopls)'
    entry do
      command '\gt'
      name ':GoTest - run tests'
      notes 'LSP features (gd, gr, K, rename...) are handled by coc-go/gopls, not vim-go.'
    end
    entry do
      command '\gr'
      name ':GoRun - run package'
    end
  end

  ##############################################################################
  category do
    id 'Linux Kernel Development'
    entry do
      command '\km'
      name 'make -j$(nproc)'
      notes 'Dispatched asynchronously. Set ARCH and CROSS_COMPILE per-project in .vimspector.json.'
    end
    entry do
      command '\kM'
      name 'make -j$(nproc) modules'
    end
    entry do
      command '\ks'
      name 'cscope: find symbol under cursor'
      notes 'Covers macro-heavy symbols that clangd cannot resolve (e.g. DEFINE_PER_CPU).'
    end
    entry do
      command '\kc'
      name 'cscope: find all callers of function'
    end
    entry do
      command '\ki'
      name 'cscope: find files #including this header'
    end
    entry do
      command '\kt'
      name 'cscope: find text string'
    end
    entry do
      command 'cscope -Rb'
      name 'Build cscope database (shell - run in kernel root)'
    end
    entry do
      command 'python3 scripts/clang-tools/gen_compile_commands.py'
      name 'Generate compile_commands.json (kernel)'
      notes 'Required for coc-clangd to work in a kernel tree.'
    end
    entry do
      command 'bear -- make'
      name 'Generate compile_commands.json via bear (generic fallback)'
    end
  end

  ##############################################################################
  category do
    id 'Android / AOSP'
    entry do
      command 'Android.bp'
      name 'Filetype: starlark (syntax via vim-starlark)'
    end
    entry do
      command 'Android.mk'
      name 'Filetype: make'
    end
    entry do
      command '*.aidl'
      name 'Filetype: java (AIDL interface)'
    end
    entry do
      command '*.hal'
      name 'Filetype: c (HIDL interface)'
    end
    entry do
      command 'development/scripts/gen_compilation_database.py'
      name 'Generate compile_commands.json (AOSP)'
    end
    entry do
      command 'ClangFormat skipped in */aosp/* paths'
      name 'Auto-format on save disabled for AOSP trees'
      notes 'Handled by ClangFormatIfNotKernel(). Place a .clang-format per module as needed.'
    end
  end

  ##############################################################################
  category do
    id 'C / C++ / Embedded'
    entry do
      command 'BufWritePre *.c *.cpp *.h *.hpp'
      name 'ClangFormat on save (automatic, skips kernel/AOSP paths)'
    end
    entry do
      command ':ClangFormat'
      name 'Format current buffer manually'
    end
  end

  ##############################################################################
  category do
    id 'Git - fugitive + gv.vim'
    entry do
      command ':G'
      name 'Git status (fugitive)'
      notes 'Full-featured status window. Press ? inside for help.'
    end
    entry do
      command ':Gvdiffsplit'
      name 'Vertical diff of current file'
    end
    entry do
      command ':G blame'
      name 'Line-by-line blame'
    end
    entry do
      command ':G push'
      name 'Push'
    end
    entry do
      command ':GV'
      name 'Commit browser (gv.vim)'
      notes 'Interactive git log for the whole repo.'
    end
    entry do
      command ':GV!'
      name 'Commits touching current file only'
    end
    entry do
      command 's'
      name 'Stage file / hunk (inside :G status window)'
    end
    entry do
      command 'u'
      name 'Unstage file / hunk (inside :G status window)'
    end
    entry do
      command 'cc'
      name 'Commit (inside :G status window)'
    end
    entry do
      command 'dd'
      name 'Diff (inside :G status window)'
    end
  end

  ##############################################################################
  category do
    id 'Editing - vim-surround'
    entry do
      command 'ys{motion}{char}'
      name 'Add surround'
      notes 'e.g. ysiw" wraps word in quotes, ysa") wraps in parens.'
    end
    entry do
      command 'yss{char}'
      name 'Surround entire line'
    end
    entry do
      command 'cs{old}{new}'
      name 'Change surround'
      notes 'e.g. cs"\' changes double to single quotes.'
    end
    entry do
      command 'ds{char}'
      name 'Delete surround'
      notes 'e.g. ds" removes surrounding double quotes.'
    end
    entry do
      command 'S{char}'
      name 'Surround selection (visual mode)'
    end
  end

  ##############################################################################
  category do
    id 'Editing - vim-visual-multi (multi-cursor)'
    entry do
      command 'Ctrl+N'
      name 'Add cursor / select next occurrence'
      notes 'WARNING: Ctrl+N is mapped to coc-explorer. Remap via g:VM_maps to restore multi-cursor.'
    end
    entry do
      command 'Ctrl+Down / Ctrl+Up'
      name 'Add cursor below / above'
    end
    entry do
      command 'n / N'
      name 'Next / Previous match (in VM mode)'
    end
    entry do
      command 'q'
      name 'Skip current and get next (in VM mode)'
    end
    entry do
      command 'Q'
      name 'Remove current cursor/selection (in VM mode)'
    end
    entry do
      command 'Tab'
      name 'Switch between cursor and extend mode (in VM mode)'
    end
  end

  ##############################################################################
  category do
    id 'UI'
    entry do
      command '\c'
      name 'Toggle cursorline highlight'
    end
    entry do
      command 'colorcolumn=80,120'
      name 'Rulers at column 80 and 120 (always on)'
    end
    entry do
      command ':Dash'
      name 'Look up word under cursor in Dash (macOS only)'
      notes 'Via rizzatti/dash.vim. Searches Dash docsets relevant to current filetype.'
    end
    entry do
      command ':DashSearch {term}'
      name 'Search specific term in Dash'
    end
    entry do
      command ':PlugInstall'
      name 'Install new plugins'
    end
    entry do
      command ':PlugUpdate'
      name 'Update all plugins'
    end
    entry do
      command ':PlugClean'
      name 'Remove unlisted plugins'
    end
  end

  notes <<-'END'
    * Reflects ~/.vimrc - local config, not vim defaults.
    * LSP powered by coc.nvim: clangd, rust-analyzer, gopls, pyright, kotlin-language-server, jdtls.
    * Kernel style (8-space tabs, no expandtab) applied automatically in /linux/, /kernel/, /aosp/ paths via vim-linux-coding-style.
    * gutentags rebuilds ctags + cscope in the background for large trees (kernel, AOSP). Cache: ~/.cache/gutentags.
    * Debugger: vimspector is installed - configure .vimspector.json per project.
    * Ctrl+N conflict: coc-explorer takes priority over vim-visual-multi default.
  END
end
