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

################ Rust ################
if [ -r "$HOME/.cargo" ]; then
  export RUSTUP_HOME="$HOME/.rustup"
  export CARGO_HOME="$HOME/.cargo"
  [ -f "${CARGO_HOME}/env" ] && source "${CARGO_HOME}/env"
fi

################ Ruby ################
if [[ -d "${HOME}/.rbenv/bin" ]]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# Load Bash It (only if installed)
export BASH_IT="${HOME}/.bash_it"
[ -f "$BASH_IT/bash_it.sh" ] && source "$BASH_IT/bash_it.sh"

# Prompt via starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# Source platform-specific and local rc
platform=$(uname | tr "[:upper:]" "[:lower:]")
[ -e "${HOME}/.bashrc_${platform}" ] && source "${HOME}/.bashrc_${platform}"
[ -e "${HOME}/.aliases" ]            && source "${HOME}/.aliases"
[ -e "${HOME}/.bash_aliases" ]       && source "${HOME}/.bash_aliases"
[ -e "${HOME}/.bashrc_local" ]       && source "${HOME}/.bashrc_local"

if command -v rg >/dev/null 2>&1; then
  export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

if command -v vim >/dev/null 2>&1; then
  export EDITOR=vim
else
  export EDITOR=vi
fi

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --bash)
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

_append_to_path "$HOME/.lmstudio/bin"
