#!/usr/bin/env bash
# Dotfiles-Installer für macOS und Linux (Desktop + Server). Idempotent.
#   ./install.sh            Symlinks + Pakete + Tools
#   ./install.sh --links    nur Symlinks
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOW=$(date +%s)
platform=$(uname | tr '[:upper:]' '[:lower:]')

has() { command -v "$1" >/dev/null 2>&1; }
run() { echo "+ $*"; "$@"; }

link() {
    local src="$DOTFILES/$1" dest="${2:-$HOME/$1}"
    if [ ! -e "$src" ]; then
        echo "! übersprungen, fehlt im Repo: $1"
        return
    fi
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ]; then
        run rm "$dest"
    elif [ -e "$dest" ]; then
        run mv "$dest" "$dest.orig-$NOW"
    fi
    run ln -s "$src" "$dest"
}

########## Symlinks ##########
[ "$DOTFILES" = "$HOME" ] && { echo "Repo darf nicht \$HOME sein"; exit 1; }

link .aliases
link .bash_profile
link .bashrc
link ".bashrc_${platform}"
link .zshrc
link ".zshrc_${platform}"
link .zsh_plugins.txt
link .editorconfig
link .gitconfig
link .gitignore
link .tigrc
link .tmux.conf
link .vimrc
link .ripgreprc
link starship.toml "$HOME/.config/starship.toml"
link bat/config    "$HOME/.config/bat/config"
link procs/config.toml "$HOME/.config/procs/config.toml"

# Debugger (XDG; lldb kennt kein XDG -> ~/.lldbinit als einziger Symlink im $HOME)
XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
link config/gdb/gdbinit   "$XDG_CONFIG/gdb/gdbinit"
link config/lldb/lldbinit "$XDG_CONFIG/lldb/lldbinit"
link lldbinit.py          "$XDG_CONFIG/lldb/lldbinit.py"
link config/lldb/lldbinit "$HOME/.lldbinit"
mkdir -p "$XDG_CONFIG/gef" "${XDG_STATE_HOME:-$HOME/.local/state}/gdb"
# altes ~/.gdbinit hätte Vorrang-Konflikte mit ~/.config/gdb/gdbinit -> beiseite
[ -e "$HOME/.gdbinit" ] && run mv "$HOME/.gdbinit" "$HOME/.gdbinit.orig-$NOW"

[ "${1:-}" = "--links" ] && exit 0

########## Pakete ##########
if [ "$platform" = "darwin" ]; then
    if ! has brew && [ ! -x /opt/homebrew/bin/brew ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    run brew bundle --file="$DOTFILES/Brewfile"
elif has apt-get; then
    # Server-Minimum; Paketnamen Debian/Ubuntu (bat -> batcat, fd -> fdfind)
    run sudo apt-get update
    run sudo apt-get install -y zsh git curl tmux vim ripgrep bat fd-find fzf jq zoxide || true
    run sudo apt-get install -y eza || echo "! eza nicht im Repo (ältere Distro) – übersprungen"
fi

# starship + mise auf Linux nach ~/.local/bin (auf macOS via Brewfile)
mkdir -p "$HOME/.local/bin"
if ! has starship; then
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
fi
if ! has mise; then
    curl -fsSL https://mise.run | MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh
fi

########## Shell ##########
# antidote klont sich beim ersten zsh-Start selbst; hier nur vorab für schnelleren Erststart
[ -d "$HOME/.antidote" ] || run git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"

if has zsh && [ "$(basename "${SHELL:-}")" != "zsh" ]; then
    echo "Login-Shell auf zsh setzen:"
    run chsh -s "$(command -v zsh)" || echo "! chsh fehlgeschlagen – manuell ausführen"
fi

########## tmux ##########
[ -d "$HOME/.tmux/plugins/tpm" ] || run git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

########## bat theme ##########
if has bat || has batcat; then
    BAT=$(has bat && echo bat || echo batcat)
    theme_dir="$($BAT --config-dir)/themes"
    if [ ! -f "$theme_dir/Catppuccin Latte.tmTheme" ]; then
        mkdir -p "$theme_dir"
        curl -fsSLo "$theme_dir/Catppuccin Latte.tmTheme" \
            "https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme"
        $BAT cache --build
    fi
fi

########## GEF (nur wo gdb existiert; auf macOS/Apple Silicon gibt es kein gdb) ##########
if has gdb || has gdb-multiarch; then
    gef_dir="${XDG_DATA_HOME:-$HOME/.local/share}/gef"
    mkdir -p "$gef_dir"
    run curl -fsSL -o "$gef_dir/gef.py" https://raw.githubusercontent.com/hugsy/gef/main/gef.py
fi

echo "Fertig. Neue Shell öffnen."
