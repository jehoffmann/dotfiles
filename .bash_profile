test -f ~/.profile && . ~/.profile
test -f ~/.bashrc && . ~/.bashrc

test -d $HOME/.cargo/bin && export PATH="$HOME/.cargo/bin:$PATH"
