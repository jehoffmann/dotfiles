# Gemeinsame Umgebung für zsh und bash (login + interaktiv). Idempotent.
# Liegt in ~/.config/shell/env.sh (Symlink ins Repo).

# XDG-Basisverzeichnisse explizit setzen, damit Tools sie zuverlässig sehen
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Runtimes verwaltet mise – deren Daten nach XDG statt ~/.cargo, ~/.rustup, ~/go
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"      # mise legt $CARGO_HOME/bin selbst in den PATH
export GOPATH="$XDG_DATA_HOME/go"             # Modul-Cache + `go install` (bin/ ist im PATH)

# Python: venvs per uv, Interpreter von mise – uv lädt keine eigenen Pythons
export PYTHON_VENV_NAME=".venv"
export PIP_REQUIRE_VIRTUALENV=true
export UV_PYTHON_PREFERENCE=only-system
export UV_PYTHON_DOWNLOADS=never

# Theme: Dracula PRO (lizenziert, lokal unter $XDG_DATA_HOME/dracula-pro), sonst freies Dracula
if [ -f "$XDG_DATA_HOME/dracula-pro/generated/starship.toml" ]; then
  export STARSHIP_CONFIG="$XDG_DATA_HOME/dracula-pro/generated/starship.toml"
  export BAT_THEME="Dracula Pro"
fi
