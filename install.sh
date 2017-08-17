#!/bin/bash

NOW=$(date +%s)

run () {
  echo $@
  $@
}

install () {
  SRC="$PWD/$1"
  DEST="$HOME/$1"

  if [ "$PWD" == "$HOME" ]; then
    exit 1
  fi

  if [ -h "$DEST" ]; then      # if $DEST is a symlink, we can probably delete it.
    run rm "$DEST"
  elif [ -e "$DEST" ]; then
    run mv "$DEST" "$DEST.orig-$NOW"
  fi
  run ln -s "$SRC" "$DEST"
}

shopt -s dotglob extglob

platform=$(uname |tr "[:upper:]" "[:lower:]")

install .bash_profile
install .gitconfig
install .gitignore
install .tigrc
install .tmux.conf
install .vimrc
install .zshrc
install .zshrc_${platform}

echo "Installing antigen"
git clone https://github.com/zsh-users/antigen.git ~/.antigen

git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "Installing tmux plugin manager"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
