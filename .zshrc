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

################ Runtimes / XDG ################
# XDG-Pfade, RUSTUP_HOME/CARGO_HOME/GOPATH, Python/uv — gemeinsam mit bash und .zprofile
[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh" ] && \
  source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"
_append_to_path $GOPATH/bin

################ Plugin settings (vor dem Laden setzen) ################
ZSH_TMUX_AUTOCONNECT=true
ZSH_TMUX_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
ZSH_TMUX_FIXTERM=false     # default-terminal setzt tmux.conf selbst

zstyle :omz:plugins:ssh-agent agent-forwarding on
zstyle :omz:plugins:ssh-agent identities id_air_jens
zstyle :omz:plugins:ssh-agent lazy yes

# Bedingungen für conditional:-Annotationen in .zsh_plugins.txt
function is_macos()   { [[ $OSTYPE == darwin* ]] }
function is_linux()   { [[ $OSTYPE == linux* ]] }
function has_python() { (( $+commands[python3] )) }
function has_tmux()   { (( $+commands[tmux] )) }
function has_ssh_agent_linux() { is_linux && (( $+commands[ssh-agent] )) }

################ antidote ################
ANTIDOTE_HOME=${ZDOTDIR:-$HOME}/.antidote
[ -f $ANTIDOTE_HOME/antidote.zsh ] || \
  git clone --depth=1 https://github.com/mattmc3/antidote.git $ANTIDOTE_HOME

source $ANTIDOTE_HOME/antidote.zsh
# Liest ~/.zsh_plugins.txt, erzeugt daraus ~/.zsh_plugins.zsh (statisch) und sourct es.
antidote load

################ Toolchains (mise: go, rust, node, python, ruby …) ################
# Kein rustup/rbenv/asdf mehr direkt – alles über ~/.config/mise/config.toml
if _has mise; then
  eval "$(mise activate zsh)"
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
  else
    # fzf < 0.48: distro key bindings (Debian/Ubuntu, Fedora, Arch/Alpine)
    for f in /usr/share/doc/fzf/examples/key-bindings.zsh \
             /usr/share/fzf/shell/key-bindings.zsh \
             /usr/share/fzf/key-bindings.zsh; do
      [ -f "$f" ] && { source "$f"; break; }
    done
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
