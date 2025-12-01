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
  return $(whence $1 >/dev/null)
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

# ssh config
zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent identities id_air_jens.pub
zstyle :omz:plugins:ssh-agent lazy yes

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
    antigen bundle terminalapp
    antigen bundle brew
    antigen bundle xcode
fi

if _has asdf; then
    antigen bundle asdf
fi

################ Python ############
if _has python3; then
  antigen bundle python
  antigen bundle pip

  alias python="python3"

  if _has virtualenv; then
    antigen bundle virtualenv
    antigen bundle virtualenvwrapper
    export VIRTUALENVWRAPPER_PYTHON=$(whence python3)
    export VIRTUALENVWRAPPER_VIRTUALENV=$(whence virtualenv)
  fi
  export PIP_RESPECT_VIRTUALENV=true
fi

################ Rust ################
if [ -r $HOME/.cargo ]; then
  _append_to_path ${CARGO_HOME}/bin

  export RUSTUP_HOME=$HOME/.rustup
  export CARGO_HOME=$HOME/.cargo

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

antigen theme gallifrey
#antigen bundle axieax/zsh-starship

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

if _has bat; then
    alias cat='bat'
fi

if _has eza; then
    alias ls='eza'
fi

if _has btop; then
    alias top=btop
fi

if _has fzf; then
  source <(fzf --zsh)
fi

# source platform specific rc
[ -e "${HOME}/.zshrc_${platform}" ] && source "${HOME}/.zshrc_${platform}"
[ -e "${HOME}/.zsh_aliases" ] && source "${HOME}/.zsh_aliases"
[ -e "${HOME}/.zshrc_local" ] && source "${HOME}/.zshrc_local"

[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && source /opt/homebrew/etc/profile.d/autojump.sh
