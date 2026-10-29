### Check OS ###
platform='unknown'
case $(uname) in
  Darwin) platform='darwin' ;;
  Linux)  platform='linux'  ;;
esac

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

# Platform specific env (Homebrew-PATH etc.) — MUSS vor Plugins und _has-Checks
# geladen werden, sonst sind brew-Tools (fzf, rg, starship …) noch nicht im PATH.
[ -e "${HOME}/.zshrc_${platform}" ] && source "${HOME}/.zshrc_${platform}"

################ Rust ################
# Nur Env — rustup wird von install.sh installiert, nicht beim Shell-Start.
if [ -r $HOME/.cargo/env ]; then
  export RUSTUP_HOME=$HOME/.rustup
  export CARGO_HOME=$HOME/.cargo
  source ${CARGO_HOME}/env
fi

################ Python ##############
if _has python3; then
  export PYTHON_VENV_NAME=".venv"
  export PIP_REQUIRE_VIRTUALENV=true
fi

################ Plugin settings (vor dem Laden setzen) ################
ZSH_TMUX_AUTOCONNECT=true

zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent identities id_air_jens
zstyle :omz:plugins:ssh-agent lazy yes

# Bedingungen für conditional:-Annotationen in .zsh_plugins.txt
function is_macos()   { [[ $OSTYPE == darwin* ]] }
function is_linux()   { [[ $OSTYPE == linux* ]] }
function has_python() { (( $+commands[python3] )) }
function has_tmux()   { (( $+commands[tmux] )) }

################ antidote ################
ANTIDOTE_HOME=${ZDOTDIR:-$HOME}/.antidote
[ -f $ANTIDOTE_HOME/antidote.zsh ] || \
  git clone --depth=1 https://github.com/mattmc3/antidote.git $ANTIDOTE_HOME

source $ANTIDOTE_HOME/antidote.zsh
# Liest ~/.zsh_plugins.txt, erzeugt daraus ~/.zsh_plugins.zsh (statisch) und sourct es.
antidote load

################ Toolchains (mise ersetzt asdf/rbenv/pyenv/nvm) ################
if _has mise; then
  eval "$(mise activate zsh)"
elif [[ -d ${HOME}/.rbenv/bin ]]; then
  _prepend_to_path $HOME/.rbenv/bin
  eval "$(rbenv init - zsh)"
fi

if _has rg; then
  export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
fi

if _has nvim; then
  export EDITOR=nvim
elif _has vim; then
  export EDITOR=vim
else
  export EDITOR=vi
fi
export VISUAL=$EDITOR

if _has fzf; then
  # fzf >= 0.48 bringt die Integration selbst mit; ältere Distro-Pakete (Debian 12) nicht
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  elif [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  fi
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

# zoxide ersetzt autojump (`z foo`, `zi` interaktiv mit fzf)
if _has zoxide; then
  eval "$(zoxide init zsh)"
fi

# Prompt — Fallback für Server ohne starship / Nerd Font
if _has starship; then
  eval "$(starship init zsh)"
else
  PROMPT='%F{red}%n@%m%f %F{yellow}%3~%f %(?.%F{green}.%F{red})❯%f '
fi

# aliases & local overrides
[ -e "${HOME}/.aliases" ]         && source "${HOME}/.aliases"
[ -e "${HOME}/.zsh_aliases" ]     && source "${HOME}/.zsh_aliases"
[ -e "${HOME}/.zshrc_local" ]     && source "${HOME}/.zshrc_local"

_append_to_path "$HOME/.lmstudio/bin"
