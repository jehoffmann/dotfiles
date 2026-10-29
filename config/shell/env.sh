# Shared environment for zsh and bash (login + interactive). Idempotent.
# Lives in ~/.config/shell/env.sh (symlink into the repo).

# Set the XDG base directories explicitly so tools see them reliably
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# mise manages the runtimes – their data goes to XDG instead of ~/.cargo, ~/.rustup, ~/go
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"      # mise puts $CARGO_HOME/bin on PATH itself
export GOPATH="$XDG_DATA_HOME/go"             # module cache + `go install` (bin/ is on PATH)

# Python: venvs via uv, interpreters from mise – uv downloads no Pythons of its own
export PYTHON_VENV_NAME=".venv"
export PIP_REQUIRE_VIRTUALENV=true
export UV_PYTHON_PREFERENCE=only-system
export UV_PYTHON_DOWNLOADS=never

# Theme: Dracula PRO (licensed, local in $XDG_DATA_HOME/dracula-pro), else free Dracula
if [ -f "$XDG_DATA_HOME/dracula-pro/generated/starship.toml" ]; then
  export STARSHIP_CONFIG="$XDG_DATA_HOME/dracula-pro/generated/starship.toml"
  export BAT_THEME="Dracula Pro"
fi
