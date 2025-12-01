#!/usr/bin/env sh

NOW=$(date +%s)

run() {
    echo $@
    $@
}

install() {
    SRC="$PWD/$1"
    DEST="$HOME/$1"

    if [ "$PWD" == "$HOME" ]; then
        exit 1
    fi

    if [ -h "$DEST" ]; then # if $DEST is a symlink, we can probably delete it.
        run rm "$DEST"
    elif [ -e "$DEST" ]; then
        run mv "$DEST" "$DEST.orig-$NOW"
    fi
    run ln -s "$SRC" "$DEST"
}

shopt -s dotglob extglob

platform=$(uname | tr "[:upper:]" "[:lower:]")

install .bashrc
install .bashrc_${platform}
install .editorconfig
install .gitconfig
install .gitignore
#install .tigrc
#install .tmux.conf
#install .vimrc
install .zshrc
install .zshrc_${platform}
#install .p10k.zsh

#echo "install bash-it"
#git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it && ~/.bash_it/install.sh -n

echo "Installing antigen"
git clone https://github.com/zsh-users/antigen.git ~/.antigen

echo "Installing tmux plugin manager"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

#pkgs = "git zsh nvim vim ripgrep bat eza fd fzf git-delta httpie thefuck"
#if ${platform} == "Darwin" then
#    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#    for pkg in ${pkgs}; do
#        brew install ${pkg}
#    done
#fi


# lldb init
mkdir -p ~/.lldb
curl --output-dir .lldb -O https://raw.githubusercontent.com/gdbinit/lldbinit/refs/heads/master/lldbinit.py
echo "command script import  ~.lldb/lldbinit.py" >>$HOME/.lldbinit

#gdbinit
curl https://raw.githubusercontent.com/gdbinit/Gdbinit/refs/heads/master/gdbinit -o ~/.gdbinit


#git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1


#echo "Install astronvim"
#git clone --depth=1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim
#git clone git@github.com:jehoffmann/astronvim_config.git ~/.config/nvim/lua/user
