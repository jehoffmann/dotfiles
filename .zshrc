### Check OS ###
platform='unknown'
case $(uname) in
  Darwin)
    platform='darwin'
    ;;
  Linux)
    platform='linux'
    ;;
esac

host=$(hostname -s)

#function gi() { curl -sLw n https://www.toptal.com/developers/gitignore/api/$@ ;}

# Returns whether the given command is executable or aliased.
function _has() {
  whence $1 >/dev/null 2>&1
}

# Prepend a directory to path, if it exists and isn't already in the path.
function _prepend_to_path() {
  if [ -d $1 -a -z ${path[(r)$1]} ]; then
    path=($1 $path);
  fi
}

# Append a directory to path, if it exists and isn't already in the path.
function _append_to_path() {
  if [ -d $1 -a -z ${path[(r)$1]} ]; then
    path=($path $1);
  fi
}

# Add common bin directories to path.
_prepend_to_path /usr/local/bin
_prepend_to_path /usr/local/sbin
_prepend_to_path $HOME/.local/bin

ANTIGEN_HOME=$HOME/.antigen
[ -f $ANTIGEN_HOME/antigen.zsh ] || git clone\
    https://github.com/zsh-users/antigen.git $ANTIGEN_HOME

# Antigen settings
source ${HOME}/.antigen/antigen.zsh

# tmux config
ZSH_TMUX_AUTOCONNECT=true

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle tmux
antigen bundle vscode
antigen bundle command-not-found
antigen bundle common-aliases
antigen bundle history
antigen bundle sudo

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions

if [[ $platform == 'darwin' ]]; then
    antigen bundle macos
    antigen bundle copypath
    antigen bundle copyfile
    antigen bundle brew
    antigen bundle xcode
fi

# .zshrc — nur auf Linux
if [[ $platform == 'linux' ]]; then
    zstyle :omz:plugins:ssh-agent agent-forwarding on
    zstyle :omz:plugins:ssh-agent identities id_air_jens
    zstyle :omz:plugins:ssh-agent lazy yes
    
    antigen bundle ssh-agent
fi


if _has asdf; then
    antigen bundle asdf
fi

################ Python ############
if _has python3; then
  export PYTHON_VENV_NAME=".venv"
  antigen bundle python
  export PIP_REQUIRE_VIRTUALENV=true
fi

if _has uv; then
  export UV_PYTHON_PREFERENCE=managed
fi

################ Rust ################
if [ -r $HOME/.cargo ]; then
  export RUSTUP_HOME=$HOME/.rustup
  export CARGO_HOME=$HOME/.cargo

  _append_to_path ${CARGO_HOME}/bin

  # Install rustup if it isn't installed already
  if ! [[ -s "${HOME}/.rustup" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- --no-modify-path -y
  fi

  [ -r ${CARGO_HOME}/env ] && source ${CARGO_HOME}/env
fi

################ Ruby ################
if [[ -d ${HOME}/.rbenv/bin ]]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

#antigen theme gallifrey
antigen bundle axieax/zsh-starship

# Tell antigen that you're done.
antigen apply

if _has rg; then
  export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

if _has vim; then
    export EDITOR=vim
else
    export EDITOR=vi
fi

if _has fzf; then
  source <(fzf --zsh)
  if _has rg; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
  if _has fd; then
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  # Ctrl+G for directory jump — avoids Option+N (tilde) conflict on German keyboard
  bindkey '^G' fzf-cd-widget
fi

# source platform specific rc
[ -e "${HOME}/.zshrc_${platform}" ] && source "${HOME}/.zshrc_${platform}"
[ -e "${HOME}/.aliases" ]         && source "${HOME}/.aliases"
[ -e "${HOME}/.zsh_aliases" ]     && source "${HOME}/.zsh_aliases"
[ -e "${HOME}/.zshrc_local" ]     && source "${HOME}/.zshrc_local"

_append_to_path "$HOME/.lmstudio/bin"

