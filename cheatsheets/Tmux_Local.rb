# encoding: utf-8
cheatsheet do
  title 'Tmux (Local Config)'
  docset_file_name 'Tmux_Local'
  keyword 'tmux'

  introduction <<-'END'
    Keybindings for ~/.tmux.conf (local config).
    Prefix = Ctrl+A (remapped from default Ctrl+B).
    Plugins: tmux-pain-control, vim-tmux-navigator, tmux-yank, tmux-resurrect, tmux-continuum, tmux-themepack.
  END

  ##############################################################################
  category do
    id 'Prefix & Meta'
    entry do
      command 'Ctrl+A'
      name 'Prefix key'
      notes 'Send prefix to inner application with Ctrl+A Ctrl+A.'
    end
    entry do
      command 'Ctrl+A Ctrl+A'
      name 'Send literal Ctrl+A to foreground application'
    end
    entry do
      command 'Ctrl+A ?'
      name 'List all keybindings'
    end
    entry do
      command 'Ctrl+A :'
      name 'Open command prompt'
    end
    entry do
      command 'Ctrl+A t'
      name 'Show clock'
    end
    entry do
      command 'Ctrl+A ~'
      name 'Show previous messages from tmux'
    end
  end

  ##############################################################################
  category do
    id 'Panes - tmux-pain-control'
    entry do
      command 'Ctrl+A |'
      name 'Split vertically (inherits current path)'
    end
    entry do
      command 'Ctrl+A -'
      name 'Split horizontally (inherits current path)'
    end
    entry do
      command 'Ctrl+A \\'
      name 'Split full-width vertically (inherits current path)'
    end
    entry do
      command 'Ctrl+A _'
      name 'Split full-width horizontally (inherits current path)'
    end
    entry do
      command 'Ctrl+A h / j / k / l'
      name 'Resize pane (small steps)'
    end
    entry do
      command 'Ctrl+A H / J / K / L'
      name 'Resize pane (large steps)'
    end
    entry do
      command 'Ctrl+A >'
      name 'Swap pane right'
    end
    entry do
      command 'Ctrl+A <'
      name 'Swap pane left'
    end
    entry do
      command 'Ctrl+A z'
      name 'Zoom pane (toggle fullscreen)'
    end
    entry do
      command 'Ctrl+A x'
      name 'Kill pane (with confirmation)'
    end
    entry do
      command 'Ctrl+A q'
      name 'Show pane numbers - press number to jump'
    end
    entry do
      command 'Ctrl+A o'
      name 'Cycle to next pane'
    end
    entry do
      command 'Ctrl+A { / }'
      name 'Swap pane with previous / next'
    end
    entry do
      command 'Ctrl+A Space'
      name 'Cycle through pane layouts'
    end
    entry do
      command 'Ctrl+A !'
      name 'Break pane out into new window'
    end
    entry do
      command 'Ctrl+A m'
      name 'Mark pane'
    end
    entry do
      command 'Ctrl+A M'
      name 'Clear marked pane'
    end
  end

  ##############################################################################
  category do
    id 'Pane Navigation - vim-tmux-navigator'
    entry do
      command 'Ctrl+H'
      name 'Move left (vim split or tmux pane)'
      notes 'Works transparently across vim splits and tmux panes - no prefix needed.'
    end
    entry do
      command 'Ctrl+J'
      name 'Move down (vim split or tmux pane)'
    end
    entry do
      command 'Ctrl+K'
      name 'Move up (vim split or tmux pane)'
    end
    entry do
      command 'Ctrl+L'
      name 'Move right (vim split or tmux pane)'
    end
    entry do
      command 'Ctrl+\\'
      name 'Move to previous pane'
    end
  end

  ##############################################################################
  category do
    id 'Windows'
    entry do
      command 'Ctrl+A c'
      name 'Create new window'
    end
    entry do
      command 'Ctrl+A ,'
      name 'Rename current window'
    end
    entry do
      command 'Ctrl+A n'
      name 'Next window'
    end
    entry do
      command 'Ctrl+A p'
      name 'Previous window'
    end
    entry do
      command 'Ctrl+A l'
      name 'Last (previously active) window'
    end
    entry do
      command 'Ctrl+A 1-9'
      name 'Switch to window N'
      notes 'Windows are 1-indexed (base-index 1 set in config).'
    end
    entry do
      command 'Ctrl+A w'
      name 'Visual window and session list (with preview)'
    end
    entry do
      command 'Ctrl+A &'
      name 'Kill window (with confirmation)'
    end
    entry do
      command 'Ctrl+A .'
      name 'Move window - set new index'
    end
    entry do
      command 'Ctrl+A f'
      name 'Find window by name'
    end
  end

  ##############################################################################
  category do
    id 'Sessions'
    entry do
      command 'Ctrl+A d'
      name 'Detach from session'
    end
    entry do
      command 'Ctrl+A s'
      name 'List and switch sessions (tree view)'
    end
    entry do
      command 'Ctrl+A $'
      name 'Rename current session'
    end
    entry do
      command 'Ctrl+A ('
      name 'Switch to previous session'
    end
    entry do
      command 'Ctrl+A )'
      name 'Switch to next session'
    end
    entry do
      command 'Ctrl+A L'
      name 'Switch to last (most recently used) session'
    end
    entry do
      command 'tmux new -s name'
      name 'Create named session (shell)'
    end
    entry do
      command 'tmux attach -t name'
      name 'Attach to named session (shell)'
    end
    entry do
      command 'tmux ls'
      name 'List sessions (shell)'
    end
  end

  ##############################################################################
  category do
    id 'Session Persistence - resurrect + continuum'
    entry do
      command 'Ctrl+A Ctrl+S'
      name 'Save session (tmux-resurrect)'
      notes 'Saves pane layout, working directories, and running processes.'
    end
    entry do
      command 'Ctrl+A Ctrl+R'
      name 'Restore session (tmux-resurrect)'
    end
    entry do
      command 'tmux-continuum'
      name 'Auto-saves session every 15 minutes (always-on background task)'
    end
  end

  ##############################################################################
  category do
    id 'Copy Mode - tmux-yank'
    entry do
      command 'Ctrl+A ['
      name 'Enter copy mode'
      notes 'Uses vi-style keys (set by tmux-sensible).'
    end
    entry do
      command 'q'
      name 'Exit copy mode'
    end
    entry do
      command 'v (or Space)'
      name 'Start selection'
    end
    entry do
      command 'V'
      name 'Start line selection'
    end
    entry do
      command 'Ctrl+V'
      name 'Start block (rectangle) selection'
    end
    entry do
      command 'y'
      name 'Yank selection to system clipboard (tmux-yank)'
    end
    entry do
      command 'Y'
      name 'Yank current line to system clipboard (tmux-yank)'
    end
    entry do
      command 'Enter'
      name 'Copy selection and exit copy mode'
    end
    entry do
      command 'Ctrl+A ]'
      name 'Paste buffer'
    end
    entry do
      command '/'
      name 'Search forward (in copy mode)'
    end
    entry do
      command '?'
      name 'Search backward (in copy mode)'
    end
    entry do
      command 'g / G'
      name 'Go to top / bottom of history'
    end
  end

  ##############################################################################
  category do
    id 'Mouse (set -g mouse on)'
    entry do
      command 'Click pane'
      name 'Focus pane'
    end
    entry do
      command 'Drag pane border'
      name 'Resize pane'
    end
    entry do
      command 'Scroll wheel'
      name 'Scroll pane (enters/exits copy mode automatically)'
    end
    entry do
      command 'Double-click word'
      name 'Select word in copy mode'
    end
    entry do
      command 'Click window tab in statusbar'
      name 'Switch window'
    end
  end

  notes <<-'END'
    * Reflects ~/.tmux.conf - local config, not tmux defaults.
    * Prefix is Ctrl+A (not the default Ctrl+B). To send Ctrl+A to a shell, press it twice.
    * Window and pane indices start at 1 (base-index 1, pane-base-index 1).
    * escape-time set to 10 ms (tmux-sensible overrides to 0) - fast Escape for vim.
    * focus-events on: vim autoread triggers correctly on pane switch.
    * True color via terminal-overrides xterm*:Tc - matches set termguicolors in vim.
    * Statusbar managed by tmux-themepack (powerline/double/yellow).
    * Status bar refreshes every 5 seconds (status-interval 5).
  END
end
