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

### Path ###
if [[ -d "$HOME/bin" ]]; then
	export PATH=$HOME/bin:$PATH
fi

[ -e "${HOME}/.zsh_aliases" ] && source "${HOME}/.zsh_aliases"
[ -e "${HOME}/.zshrc_local" ] && source "${HOME}/.zshrc_local"

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
antigen bundle adb
antigen bundle git
antigen bundle tmux
antigen bundle sublime
antigen bundle command-not-found
antigen bundle common-aliases
antigen bundle history
antigen bundle docker
antigen bundle sudo
antigen bundle vundle

antigen bundle gpg-agent

antigen bundle python
antigen bundle pip

antigen bundle ruby
antigen bundle rbenv

antigen bundle djui/alias-tips

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

antigen bundle chrissicool/zsh-256color

antigen bundle Tarrasch/zsh-autoenv
#antigen bundle kennethreitz/autoenv

# Fortunes
#T2C_FORTUNE_DIR=${HOME}/.t2c_fortunes
#T2C_FORTUNE_URL=ssh://git@bitbucket.org/Satarus/t2c_fortunes.git
#antigen bundle ssh://git@bitbucket.org/Satarus/t2c_fortunes.git contrib/t2c_fortunes --branch=next

if [[ $platform == 'darwin' ]]; then
    antigen bundle osx
    antigen bundle copydir
    antigen bundle copyfile
    antigen bundle terminalapp
    antigen bundle brew
    antigen bundle xcode
    antigen bundle vagrant
fi

# Python config
export PIP_RESPECT_VIRTUALENV=true
# cache pip-installed packages to avoid re-downloading
export WORKON_HOME=$HOME/.virtualenvs
#export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'

antigen bundle virtualenv
antigen bundle virtualenvwrapper

# Load the theme.
antigen theme gallifrey

# Tell antigen that you're done.
antigen apply

# source platform specific rc
[ -e "${HOME}/.zshrc_${platform}" ] && source "${HOME}/.zshrc_${platform}"

# Setup android env
if [[ -d ${HOME}/Development/Android/sdk ]]; then
    export ANDROID_HOME=${HOME}/Development/Android/sdk
    export PATH=${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:$PATH
    if [[ -d ${ANDROID_HOME}/ndk-bundle ]]; then
        export PATH=${ANDROID_HOME}/ndk-bundle:${PATH}
    fi
fi

alias tmux="tmux -2"
alias pipu="pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U"
alias pipu3="pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip3 install -U"
