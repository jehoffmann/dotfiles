#!/usr/bin/env bash

# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
esac

# History
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend

function _prepend_to_path() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="$1:$PATH"
  fi
}

function _append_to_path() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="$PATH:$1"
  fi
}

# Add common bin directories to path.
_prepend_to_path /usr/local/bin
_prepend_to_path /usr/local/sbin
_prepend_to_path "$HOME/.local/bin"

# Platform specific env (Homebrew PATH) — before any command -v checks
platform=$(uname | tr "[:upper:]" "[:lower:]")
[ -e "${HOME}/.bashrc_${platform}" ] && source "${HOME}/.bashrc_${platform}"

################ Runtimes / XDG ################
[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh" ] && \
  source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"
_append_to_path "$GOPATH/bin"

################ Toolchains (mise) ################
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# Load Bash It (only if installed)
export BASH_IT="${HOME}/.bash_it"
[ -f "$BASH_IT/bash_it.sh" ] && source "$BASH_IT/bash_it.sh"

# aliases & local overrides
[ -e "${HOME}/.aliases" ]            && source "${HOME}/.aliases"
[ -e "${HOME}/.bash_aliases" ]       && source "${HOME}/.bash_aliases"
[ -e "${HOME}/.bashrc_local" ]       && source "${HOME}/.bashrc_local"

if command -v rg >/dev/null 2>&1; then
  export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
elif command -v vim >/dev/null 2>&1; then
  export EDITOR=vim
else
  export EDITOR=vi
fi
export VISUAL=$EDITOR

if command -v fzf >/dev/null 2>&1; then
  if fzf --bash >/dev/null 2>&1; then
    source <(fzf --bash)
  else
    # fzf < 0.48: distro key bindings (Debian/Ubuntu, Fedora, Arch/Alpine)
    for f in /usr/share/doc/fzf/examples/key-bindings.bash \
             /usr/share/fzf/shell/key-bindings.bash \
             /usr/share/fzf/key-bindings.bash; do
      [ -f "$f" ] && { source "$f"; break; }
    done
  fi
  if command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  if command -v fd >/dev/null 2>&1; then
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  # Ctrl+G for directory jump — avoids Option+N (tilde) conflict on German keyboard
  bind -x '"\C-g": __fzf_cd__'
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# Prompt via starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

_append_to_path "$HOME/.lmstudio/bin"
