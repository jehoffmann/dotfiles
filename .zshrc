### Check OS ###
platform='unknown'
case `uname` in
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

antigen bundle python
antigen bundle pip

antigen bundle ruby
antigen bundle rbenv

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

if [[ $platform == "darwin" ]]; then

    if [[ -z $(which brew) ]]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    export DOCKER_HOST='tcp://127.0.0.1:2375' 

    # change path and set homebrew bin in front of path
    export PATH="/usr/local/bin:$PATH"

    export JAVA_HOME=$(/usr/libexec/java_home)
    export ANT_HOME=/usr/local/opt/ant/libexec
    export GROOVY_HOME=/usr/local/opt/groovy/libexec
    export GRADLE_HOME=/usr/local/opt/gradle/libexec

    if [[ -d ${HOME}/Development/sdk/android-sdk-macosx ]]; then
        export ANDROID_SDK_HOME=${HOME}/Development/sdk/android-sdk-macosx
        export ANDROID_AVD_HOME=${HOME}/.android/avd
        export ANDROID_HOME=${ANDROID_SDK_HOME}
    fi

    if [[ -d ${ANDROID_HOME}/ndk-bundle ]]; then
        export ANDROID_NDK_HOME=${ANDROID_HOME}/ndk-bundle
        export PATH=${ANDROID_NDK_HOME}:${PATH}
    fi

    if [[ -d "/Volumes/ESPTools/esp-open-sdk/xtensa-lx106-elf/bin" ]]; then
        export PATH=$PATH:/Volumes/ESPTools/esp-open-sdk/xtensa-lx106-elf/bin
    fi

elif [[ $platform == "linux" ]]; then
    
    export JAVA_HOME=/usr/lib/jvm/java-7-oracle
    export ANT_HOME=/usr/share/ant
    export GROOVY_HOME=/usr/share/groovy
    export GRADLE_HOME=/usr/share/gradle

    if [[ -d ${HOME}/Development/sdk/android-sdk-linux ]]; then
        export ANDROID_SDK_HOME=${HOME}/Development/sdk/android-sdk-linux
        export ANDROID_AVD_HOME=${HOME}/.android/avd
        export ANDROID_HOME=${ANDROID_SDK_HOME}
    fi

    if [[ -d ${HOME}/Development/sdk/android-ndk-r10d ]]; then
        export ANDROID_NDK_HOME=${HOME}/Development/sdk/android-ndk-r10d
        export PATH=${ANDROID_NDK_HOME}:${PATH}
    fi
fi

if [[ -n "${ANDROID_SDK_HOME}" ]]; then
    export PATH=${ANDROID_SDK_HOME}/tools:${ANDROID_SDK_HOME}/platform-tools:$PATH
fi

alias tmux="tmux -2"
alias pipu="pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U"
