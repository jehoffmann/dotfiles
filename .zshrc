# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

function gi() { curl -sLw n https://www.toptal.com/developers/gitignore/api/$@ ;}

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
zstyle :omz:plugins:ssh-agent identities id_rsa

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
antigen bundle chrissicool/zsh-256color
antigen bundle mattmc3/zsh-safe-rm

antigen theme romkatv/powerlevel10k

if [[ $platform == 'darwin' ]]; then
    antigen bundle osx
    antigen bundle copydir
    antigen bundle copyfile
    antigen bundle terminalapp
    antigen bundle brew
    antigen bundle xcode
fi

if _has docker; then
  # https://github.com/ohmyzsh/ohmyzsh/issues/11817
  antigen bundle docker
fi

################ Python ############
if _has python3; then
  antigen bundle python
  antigen bundle pip

  alias python="python3"
  alias pipu="pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip3 install -U"

  if _has virtualenv; then
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

# Tell antigen that you're done.
antigen apply

if _has rg; then
  export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

if _has nvim; then
    export EDITOR=nvim
    alias vim='nvim'
elif _has vim; then
    export EDITOR=vim
else
    export EDITOR=vi
fi

if  _has bat; then
    alias cat='bat'
fi

if _has eza; then
    alias ls='eza'
fi


# source platform specific rc
[ -e "${HOME}/.zshrc_${platform}" ] && source "${HOME}/.zshrc_${platform}"
[ -e "${HOME}/.zsh_aliases" ] && source "${HOME}/.zsh_aliases"
[ -e "${HOME}/.zshrc_local" ] && source "${HOME}/.zshrc_local"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && source /opt/homebrew/etc/profile.d/autojump.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/jhoffmann/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/jhoffmann/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/jhoffmann/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/jhoffmann/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
