# Login-Shell: Umgebung für GUI-Apps/IDEs (CLion, VS Code lesen das Login-Env)
# Interaktive Shells bekommen danach in .zshrc das volle `mise activate`.

[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh" ] && \
  source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.sh"

# Homebrew / Linuxbrew
for _brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [[ -x $_brew ]] && { eval "$($_brew shellenv)"; break; }
done
unset _brew

# mise-Shims: Runtimes auch für Prozesse ohne interaktive Shell
if [[ -x $HOME/.local/bin/mise ]]; then
  eval "$($HOME/.local/bin/mise activate zsh --shims)"
elif (( $+commands[mise] )); then
  eval "$(mise activate zsh --shims)"
fi
