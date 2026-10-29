# Login shell: environment for GUI apps/IDEs (CLion, VS Code read the login env).
# Interactive shells additionally get the full `mise activate` in .zshrc.

[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh" ] && \
  source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"

# Homebrew / Linuxbrew
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x $_brew ]] && { eval "$($_brew shellenv)"; break; }
done
unset _brew

# mise shims: runtimes also for processes without an interactive shell
if [[ -x $HOME/.local/bin/mise ]]; then
  eval "$($HOME/.local/bin/mise activate zsh --shims)"
elif (( $+commands[mise] )); then
  eval "$(mise activate zsh --shims)"
fi
