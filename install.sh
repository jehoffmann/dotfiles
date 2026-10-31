#!/bin/sh
# Dotfiles installer for macOS and Linux (Ubuntu/Debian, Fedora, Arch, Alpine). Idempotent.
#
#   ./install.sh                     links + packages + tools, profile auto-detected
#   ./install.sh --profile server    headless: shell/CLI tools only, no language runtimes
#   ./install.sh --profile desktop   adds runtimes (mise), Nerd Font, clipboard tools
#   ./install.sh --links             only (re)create symlinks
#   ./install.sh --no-root           never use sudo/doas: no system packages, no chsh;
#                                    missing CLI tools come from mise in $HOME
#   ./install.sh --root              allow sudo/doas again (undoes --no-root)
#   ./install.sh --cleanup [--yes]   list leftovers of older setups; --yes deletes them
#
# Profile and --no-root are remembered in ~/.config/dotfiles/.

# ── POSIX preamble ──────────────────────────────────────────────────────────
# Re-execute in a regular bash: Alpine/BusyBox ships without bash, and on macOS
# /bin/sh is bash 3.2 in POSIX mode. DOTFILES_REEXEC guards against loops.
_needs_bash=false
[ -z "${BASH_VERSION:-}" ] && _needs_bash=true
case ":${SHELLOPTS:-}:" in *:posix:*) _needs_bash=true ;; esac
if $_needs_bash && [ -z "${DOTFILES_REEXEC:-}" ]; then
    if ! command -v bash >/dev/null 2>&1 && command -v apk >/dev/null 2>&1; then
        if [ "$(id -u)" -eq 0 ]; then apk add --no-cache bash
        elif command -v doas >/dev/null 2>&1; then doas apk add --no-cache bash
        else sudo apk add --no-cache bash
        fi
    fi
    DOTFILES_REEXEC=1 exec env -u POSIXLY_CORRECT -u SHELLOPTS bash "$0" "$@"
fi
unset _needs_bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOW=$(date +%s)
platform=$(uname | tr '[:upper:]' '[:lower:]')
XDG_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
PROFILE_FILE="$XDG_CONFIG/dotfiles/profile"
NO_ROOT_FILE="$XDG_CONFIG/dotfiles/no-root"

LINKS_ONLY=false
CLEANUP=false
ASSUME_YES=false
PROFILE=""
NO_ROOT=""
while [ $# -gt 0 ]; do
    case "$1" in
        --links)   LINKS_ONLY=true ;;
        --cleanup) CLEANUP=true ;;
        -y|--yes)  ASSUME_YES=true ;;
        --profile) PROFILE="${2:?--profile needs desktop|server}"; shift ;;
        --no-root) NO_ROOT=true ;;
        --root)    NO_ROOT=false ;;
        -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

has()  { command -v "$1" >/dev/null 2>&1; }
run()  { echo "+ $*"; "$@"; }
warn() { echo "! $*" >&2; }

# version_ge A B -> true if dotted version A >= B (pure bash; BusyBox sort has no -V)
version_ge() {
    local IFS=. i x y
    # shellcheck disable=SC2206  # intentional split on dots
    local -a a=($1) b=($2)
    for i in 0 1 2; do
        x=${a[i]:-0}; y=${b[i]:-0}; x=${x//[!0-9]/}; y=${y//[!0-9]/}
        (( 10#${x:-0} > 10#${y:-0} )) && return 0
        (( 10#${x:-0} < 10#${y:-0} )) && return 1
    done
    return 0
}
tool_version() { "$@" 2>/dev/null | grep -Eo '[0-9]+(\.[0-9]+)+' | head -n1; }

# Run as root: directly, via sudo or via doas
as_root() {
    if $NO_ROOT; then warn "skipped (--no-root): $*"; return 1; fi
    if [ "$(id -u)" -eq 0 ]; then "$@"
    elif has sudo; then sudo "$@"
    elif has doas; then doas "$@"
    else warn "need root for: $*"; return 1
    fi
}

link() {
    local src="$DOTFILES/$1" dest="${2:-$HOME/$1}"
    if [ ! -e "$src" ]; then
        warn "skipped, missing in repo: $1"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ]; then
        [ "$(readlink "$dest")" = "$src" ] && return 0
        run rm "$dest"
    elif [ -e "$dest" ]; then
        run mv "$dest" "$dest.orig-$NOW"
    fi
    run ln -s "$src" "$dest"
}

# ── Distro + profile detection ──────────────────────────────────────────────
DISTRO="$platform"
if [ "$platform" = linux ] && [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case " ${ID:-} ${ID_LIKE:-} " in
        *" alpine "*)                      DISTRO=alpine ;;
        *" arch "*)                        DISTRO=arch ;;
        *" fedora "*|*" rhel "*)           DISTRO=fedora ;;
        *" debian "*|*" ubuntu "*)         DISTRO=debian ;;
    esac
fi

detect_profile() {
    [ "$platform" = darwin ] && { echo desktop; return; }
    [ "$DISTRO" = alpine ] && { echo server; return; }
    if [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}${XDG_CURRENT_DESKTOP:-}" ]; then echo desktop; return; fi
    if has systemctl && [ "$(systemctl get-default 2>/dev/null)" = graphical.target ]; then echo desktop; return; fi
    echo server
}
[ -n "$PROFILE" ] || PROFILE=$(cat "$PROFILE_FILE" 2>/dev/null || detect_profile)
case "$PROFILE" in desktop|server) ;; *) echo "invalid profile: $PROFILE" >&2; exit 1 ;; esac
mkdir -p "$(dirname "$PROFILE_FILE")" && echo "$PROFILE" >"$PROFILE_FILE"

# no-root mode: explicit flag, remembered choice, or nothing to elevate with
case "$NO_ROOT" in
    true)  touch "$NO_ROOT_FILE" ;;
    false) rm -f "$NO_ROOT_FILE" ;;
esac
if [ -e "$NO_ROOT_FILE" ]; then
    NO_ROOT=true
elif [ "$NO_ROOT" != false ] && [ "$(id -u)" -ne 0 ] && ! has sudo && ! has doas; then
    NO_ROOT=true
else
    NO_ROOT=false
fi
if $NO_ROOT; then echo "== no-root mode: system packages and chsh are skipped"; fi
echo "== dotfiles: $DISTRO, profile $PROFILE"

########## Cleanup ##########
# Leftovers of older setups. Dry run by default; --yes applies. Only fixed,
# known paths below $HOME are touched, never anything the user created.
cleanup() {
    local mode=dry-run p t
    $ASSUME_YES && mode=apply
    echo "== cleanup ($mode)"

    remove() {   # remove <path> <reason>
        case "$1" in "$HOME"/?*) ;; *) warn "refusing to remove $1"; return 0 ;; esac
        if $ASSUME_YES; then run rm -rf "$1"; else echo "  would remove $1  ($2)"; fi
    }
    move() {     # move <from> <to> <reason>
        if $ASSUME_YES; then mkdir -p "$(dirname "$2")" && run mv "$1" "$2"
        else echo "  would move   $1 -> $2  ($3)"; fi
    }
    # list the non-empty directory <dir>/bin, "" if empty or missing
    bin_contents() { if [ -d "$1/bin" ]; then ls -A "$1/bin" | tr "\n" " "; fi; }

    [ -d "$HOME/.antigen" ] && remove "$HOME/.antigen" "Antigen, replaced by antidote"
    [ -d "$HOME/.lldb" ]    && remove "$HOME/.lldb" "old lldbinit download, now config/lldb"

    # old tmux plugin dir; keep saved resurrect sessions (resurrect uses XDG without ~/.tmux)
    if [ -d "$HOME/.tmux" ]; then
        t="$XDG_DATA/tmux/resurrect"
        if [ -d "$HOME/.tmux/resurrect" ] && [ ! -e "$t" ]; then
            move "$HOME/.tmux/resurrect" "$t" "saved tmux sessions"
        elif [ -d "$HOME/.tmux/resurrect" ]; then
            warn "keeping ~/.tmux: both ~/.tmux/resurrect and $t exist – merge by hand"
            t=""
        fi
        [ -n "$t" ] && remove "$HOME/.tmux" "old TPM plugins, now ~/.config/tmux/plugins"
    fi

    # pre-XDG Rust; keep it if `cargo install` put own tools there
    if [ -d "$HOME/.cargo" ] && [ "${CARGO_HOME:-$XDG_DATA/cargo}" != "$HOME/.cargo" ]; then
        local extra=""
        for p in $(bin_contents "$HOME/.cargo"); do
            case "$p" in
                cargo|cargo-clippy|cargo-fmt|cargo-miri|clippy-driver|rls|rust-analyzer|rust-gdb|rust-gdbgui|rust-lldb|rustc|rustdoc|rustfmt|rustup) ;;
                *) extra="$extra $p" ;;
            esac
        done
        if [ -n "$extra" ]; then
            warn "keeping ~/.cargo – it contains tools from 'cargo install':$extra"
        else
            remove "$HOME/.cargo" "pre-XDG Rust, now $XDG_DATA/cargo"
        fi
    fi
    if [ -d "$HOME/.rustup" ] && [ "${RUSTUP_HOME:-$XDG_DATA/rustup}" != "$HOME/.rustup" ]; then
        remove "$HOME/.rustup" "pre-XDG Rust, now $XDG_DATA/rustup"
    fi

    # pre-XDG GOPATH; keep it if `go install` put tools there
    if [ -d "$HOME/go" ] && [ "${GOPATH:-$XDG_DATA/go}" != "$HOME/go" ]; then
        p=$(bin_contents "$HOME/go")
        if [ -n "$p" ]; then
            warn "keeping ~/go – bin/ contains: $p(delete by hand if these came from vim-go)"
        else
            remove "$HOME/go" "pre-XDG GOPATH, now $XDG_DATA/go"
        fi
    fi

    # backups made by link()
    for p in "$HOME"/.*.orig-[0-9]* "$HOME"/*.orig-[0-9]* "$XDG_CONFIG"/*/*.orig-[0-9]* "$XDG_CONFIG"/*/*/*.orig-[0-9]*; do
        [ -e "$p" ] || [ -L "$p" ] || continue
        remove "$p" "backup made by install.sh"
    done

    # dangling symlinks that point into this repo (files removed from the repo)
    for p in "$HOME"/.* "$HOME"/* "$XDG_CONFIG"/* "$XDG_CONFIG"/*/* "$XDG_CONFIG"/*/*/*; do
        [ -L "$p" ] && [ ! -e "$p" ] || continue
        case "$(readlink "$p")" in "$DOTFILES"/*) remove "$p" "dangling link into the repo" ;; esac
    done

    $ASSUME_YES || echo "== dry run only – rerun with --cleanup --yes to apply"
}

if $CLEANUP; then
    # shellcheck disable=SC1091
    [ -r "$DOTFILES/config/shell/env.sh" ] && . "$DOTFILES/config/shell/env.sh"
    cleanup
    exit 0
fi

########## Symlinks ##########
[ "$DOTFILES" = "$HOME" ] && { echo "repo must not be \$HOME" >&2; exit 1; }

# ~/.gitconfig_user: created once from the template (asks for identity and
# signing key when run interactively), then only the managed block at its end
# is rewritten to match the installed git version.
git_user_config() {
    local f="$HOME/.gitconfig_user" gv name email key keyfile tmp line
    gv=$(tool_version git --version)

    if [ ! -e "$f" ]; then
        name=${DOTFILES_GIT_NAME:-}; email=${DOTFILES_GIT_EMAIL:-}; key=${DOTFILES_GIT_SIGNINGKEY:-}
        local defkey=""
        for keyfile in "$HOME"/.ssh/*.pub; do [ -e "$keyfile" ] && { defkey=$keyfile; break; }; done
        if [ -t 0 ]; then
            echo "== creating $f"
            [ -n "$name" ]  || read -r -p "   git user.name: " name
            [ -n "$email" ] || read -r -p "   git user.email: " email
            [ -n "$key" ]   || { read -r -p "   SSH public key for signing [${defkey:-none}]: " key; key=${key:-$defkey}; }
        fi
        key=${key/#\~/$HOME}
        local l_name="    # name = (set me)" l_email="    # email = (set me)" l_key="    # signingkey = ~/.ssh/id_ed25519.pub"
        [ -n "$name" ]  && l_name="    name = $name"
        [ -n "$email" ] && l_email="    email = $email"
        case "$key" in
            "$HOME"/*) l_key="    signingkey = ~${key#"$HOME"}" ;;
            ?*)        l_key="    signingkey = $key" ;;
        esac
        sed -e "s|^    name = @NAME@|$l_name|" -e "s|^    email = @EMAIL@|$l_email|" \
            -e "s|^    @SIGNINGKEY@|$l_key|" \
            "$DOTFILES/config/git/gitconfig_user.template" >"$f"
        [ -n "$name" ] && [ -n "$email" ] || warn "set user.name/user.email in $f"
        # allowed_signers lets git verify your own SSH signatures
        if [ -n "$key" ] && [ -n "$email" ] && [ -r "$key" ]; then
            line="$email $(cut -d' ' -f1,2 "$key")"
            grep -qsF "$line" "$HOME/.ssh/allowed_signers" || echo "$line" >>"$HOME/.ssh/allowed_signers"
        fi
    fi

    # rewrite the managed block (drop the old one and trailing blank lines)
    tmp=$(mktemp)
    awk '/^# >>> dotfiles/{skip=1} !skip{l[++n]=$0} /^# <<< dotfiles/{skip=0}
         END{while (n>0 && l[n]=="") n--; for (i=1;i<=n;i++) print l[i]}' "$f" >"$tmp"
    {
        cat "$tmp"
        echo
        echo "# >>> dotfiles: managed by install.sh for git $gv – edits inside are overwritten >>>"
        if version_ge "$gv" 2.34; then
            printf '[help]\n    autocorrect = prompt\n'
            printf '[gpg]\n    format = ssh\n[gpg "ssh"]\n    allowedSignersFile = ~/.ssh/allowed_signers\n'
        else
            echo "# git < 2.34: no SSH signing, no autocorrect=prompt"
        fi
        if version_ge "$gv" 2.35; then
            printf '[merge]\n    conflictstyle = zdiff3\n'
        fi
        echo "# <<< dotfiles <<<"
    } >"$f"
    rm -f "$tmp"
}

link_all() {
    # ~/.ssh is expected by the OMZ ssh-agent plugin and the ssh multiplexing aliases
    mkdir -p "$HOME/.ssh/sockets" && chmod 700 "$HOME/.ssh"

    link .aliases
    link .bash_profile
    link .bashrc
    link ".bashrc_${platform}"
    link .zshrc
    link ".zshrc_${platform}"
    link .zsh_plugins.txt
    link .zprofile
    link .editorconfig
    link .gitconfig
    link .gitignore
    link .tigrc
    link .vimrc
    link .ripgreprc
    link starship.toml                 "$XDG_CONFIG/starship.toml"
    link bat/config                    "$XDG_CONFIG/bat/config"
    link procs/config.toml             "$XDG_CONFIG/procs/config.toml"
    link config/shell/env.sh           "$XDG_CONFIG/shell/env.sh"
    link config/coc/coc-settings.json  "$XDG_CONFIG/coc/coc-settings.json"

    # tmux: XDG config (version differences are handled inside via %if)
    link config/tmux/tmux.conf "$XDG_CONFIG/tmux/tmux.conf"
    # tmux < 3.1 does not read ~/.config/tmux/tmux.conf
    if has tmux && ! version_ge "$(tool_version tmux -V)" 3.1; then
        link config/tmux/tmux.conf "$HOME/.tmux.conf"
    elif [ -L "$HOME/.tmux.conf" ]; then
        run rm "$HOME/.tmux.conf"       # would shadow the XDG config
    fi

    # git: identity, signing key and version-dependent options
    has git && git_user_config

    # mise: settings always, language runtimes only on desktops
    link config/mise/config.toml "$XDG_CONFIG/mise/config.toml"
    if [ "$PROFILE" = desktop ]; then
        link config/mise/conf.d/20-dev.toml "$XDG_CONFIG/mise/conf.d/20-dev.toml"
    elif [ -L "$XDG_CONFIG/mise/conf.d/20-dev.toml" ]; then
        run rm "$XDG_CONFIG/mise/conf.d/20-dev.toml"
    fi

    # Linux desktop sessions: PATH/env for GUI apps (systemd environment.d)
    if [ "$platform" = linux ] && [ "$PROFILE" = desktop ]; then
        link config/environment.d/10-dotfiles.conf "$XDG_CONFIG/environment.d/10-dotfiles.conf"
    fi

    # Debuggers (XDG; lldb has no XDG support -> ~/.lldbinit is the only link in $HOME)
    link config/gdb/gdbinit   "$XDG_CONFIG/gdb/gdbinit"
    link config/lldb/lldbinit "$XDG_CONFIG/lldb/lldbinit"
    link lldbinit.py          "$XDG_CONFIG/lldb/lldbinit.py"
    link config/lldb/lldbinit "$HOME/.lldbinit"
    mkdir -p "$XDG_CONFIG/gef" "${XDG_STATE_HOME:-$HOME/.local/state}/gdb"
    # a legacy ~/.gdbinit would compete with ~/.config/gdb/gdbinit
    if [ -e "$HOME/.gdbinit" ] && [ ! -L "$HOME/.gdbinit" ]; then
        run mv "$HOME/.gdbinit" "$HOME/.gdbinit.orig-$NOW"
    fi
}

dracula_pro() {
    # licensed theme, only if installed locally (see README)
    [ -d "$XDG_DATA/dracula-pro" ] && { "$DOTFILES/bin/dracula-pro-setup" || true; }
    return 0
}

link_all
dracula_pro
$LINKS_ONLY && exit 0

########## Packages ##########
# Optional packages are installed one by one, so a missing package on an
# older release does not abort the whole run. Gaps are filled by mise below.
pkg_try() { for p in "$@"; do "${PKG_INSTALL[@]}" "$p" >/dev/null 2>&1 && echo "  ok $p" || echo "  -- $p (not available)"; done; }

BASE=() OPTIONAL=() DESKTOP=()
case "$DISTRO" in
    darwin)
        if ! has brew && [ ! -x /opt/homebrew/bin/brew ]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
        run brew bundle --file="$DOTFILES/Brewfile"
        ;;
    debian)
        export DEBIAN_FRONTEND=noninteractive
        $NO_ROOT || run as_root apt-get update -qq
        PKG_INSTALL=(as_root apt-get install -y -qq --no-install-recommends)
        BASE=(zsh bash git curl ca-certificates tmux vim)
        OPTIONAL=(less openssh-client ncurses-term ripgrep bat fd-find fzf jq btop zoxide eza git-delta procps file)
        DESKTOP=(gdb xclip wl-clipboard fontconfig xz-utils universal-ctags)
        ;;
    fedora)
        PKG_INSTALL=(as_root dnf install -y -q)
        BASE=(zsh bash git curl tmux vim-enhanced)
        OPTIONAL=(less openssh-clients util-linux-user ncurses ripgrep bat fd-find fzf jq btop zoxide eza git-delta procps-ng file)
        DESKTOP=(gdb xclip wl-clipboard fontconfig xz ctags)
        ;;
    arch)
        $NO_ROOT || run as_root pacman -Sy --noconfirm
        PKG_INSTALL=(as_root pacman -S --needed --noconfirm)
        BASE=(zsh bash git curl tmux vim)
        OPTIONAL=(less openssh ncurses ripgrep bat fd fzf jq btop zoxide eza git-delta lazygit starship mise github-cli procps-ng file)
        DESKTOP=(gdb xclip wl-clipboard fontconfig ctags ttf-jetbrains-mono-nerd)
        ;;
    alpine)
        $NO_ROOT || run as_root apk update -q
        PKG_INSTALL=(as_root apk add -q --no-cache)
        BASE=(zsh bash git curl tmux vim)
        OPTIONAL=(less openssh-client ncurses ncurses-terminfo shadow coreutils procps ripgrep bat fd fzf jq btop zoxide eza delta lazygit starship mise file)
        DESKTOP=()
        ;;
    *) warn "unknown distro – skipping packages" ;;
esac

if $NO_ROOT && [ "$DISTRO" != darwin ]; then
    for t in zsh git curl tmux vim; do has "$t" || warn "$t is not installed and cannot be without root"; done
elif [ "$DISTRO" != darwin ] && [ ${#BASE[@]} -gt 0 ]; then
    echo "== base packages"
    run "${PKG_INSTALL[@]}" "${BASE[@]}" >/dev/null
    echo "== optional packages"
    pkg_try "${OPTIONAL[@]}"
    if [ "$PROFILE" = desktop ] && [ ${#DESKTOP[@]} -gt 0 ]; then
        echo "== desktop packages"
        pkg_try "${DESKTOP[@]}"
    fi
fi

# relink: tmux/git version gates depend on what was just installed
link_all

########## mise ##########
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
if ! has mise; then
    curl -fsSL https://mise.run | MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh || warn "mise install failed (offline?)"
fi
# shellcheck disable=SC1091
. "$DOTFILES/config/shell/env.sh"    # RUSTUP_HOME, CARGO_HOME, GOPATH … so mise installs to XDG
mkdir -p "$GOPATH/bin"

# Fill gaps: CLI tools the distro does not package (or only in too old a version)
# go into a machine-local mise config that is not part of the repo.
LOCAL_MISE="$XDG_CONFIG/mise/conf.d/90-local.toml"
if [ "$DISTRO" != darwin ]; then
    missing=()
    has rg                      || missing+=(ripgrep)
    has bat || has batcat       || missing+=(bat)
    has fd  || has fdfind       || missing+=(fd)
    has eza                     || missing+=(eza)
    has zoxide                  || missing+=(zoxide)
    has starship                || missing+=(starship)
    has delta                   || missing+=(delta)
    has lazygit                 || missing+=(lazygit)
    has jq                      || missing+=(jq)
    if ! has fzf || ! version_ge "$(tool_version fzf --version)" 0.48; then
        missing+=(fzf)          # shell integration needs fzf >= 0.48
    fi
    if [ ${#missing[@]} -gt 0 ]; then
        echo "== via mise (not packaged here): ${missing[*]}"
        mkdir -p "$(dirname "$LOCAL_MISE")"
        { echo "# generated by install.sh – tools missing from the $DISTRO packages"
          echo "[tools]"
          for t in "${missing[@]}"; do echo "$t = \"latest\""; done
        } >"$LOCAL_MISE"
    fi
fi
if has mise; then
    run mise install || warn "mise install failed – rerun 'mise install' later"
else
    warn "mise missing – runtimes and gap tools not installed"
fi

########## Nerd Font (Linux desktop) ##########
if [ "$platform" = linux ] && [ "$PROFILE" = desktop ] && has fc-list && ! fc-list | grep -qi "JetBrainsMono.*Nerd\|JetBrainsMono NF"; then
    font_dir="$XDG_DATA/fonts/JetBrainsMonoNerdFont"
    mkdir -p "$font_dir"
    if curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz | tar -xJ -C "$font_dir"; then
        run fc-cache -f "$font_dir"
    else
        warn "Nerd Font download failed"
    fi
fi

########## Shell ##########
# antidote clones itself on first zsh start; done here for a faster first start
[ -d "$HOME/.antidote" ] || run git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"

if has zsh && [ "$(basename "${SHELL:-}")" != zsh ]; then
    zsh_path=$(command -v zsh)
    if ! $NO_ROOT; then
        echo "== set login shell to zsh"
        grep -qx "$zsh_path" /etc/shells 2>/dev/null || echo "$zsh_path" | as_root tee -a /etc/shells >/dev/null
        as_root chsh -s "$zsh_path" "$(id -un)" || warn "chsh failed – run: chsh -s $zsh_path"
    elif ! grep -qs "dotfiles: start zsh" "$HOME/.bashrc_local"; then
        # login shell is managed elsewhere (LDAP, salt, …): hop from bash to zsh on login
        echo "== login shell stays $(basename "${SHELL:-bash}"); bash login shells exec zsh (~/.bashrc_local)"
        cat >>"$HOME/.bashrc_local" <<'EOF'
# dotfiles: start zsh – the login shell cannot be changed here. Only bash *login*
# shells hop, so running `bash` by hand still gives bash. DOTFILES_NO_ZSH=1 stays in bash.
if shopt -q login_shell && [ -t 1 ] && [ -z "${DOTFILES_NO_ZSH:-}" ] && command -v zsh >/dev/null 2>&1; then
  exec zsh -l
fi
EOF
    fi
elif ! has zsh; then
    warn "zsh not available – bash with the same aliases and prompt is used instead"
fi

########## tmux ##########
TPM_DIR="$XDG_CONFIG/tmux/plugins/tpm"
[ -d "$TPM_DIR" ] || run git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
# tmux installs missing plugins itself on start (see tmux.conf)

########## GEF (only where gdb exists; Apple Silicon has no gdb) ##########
if has gdb || has gdb-multiarch; then
    gef_dir="$XDG_DATA/gef"
    mkdir -p "$gef_dir"
    run curl -fsSL -o "$gef_dir/gef.py" https://raw.githubusercontent.com/hugsy/gef/main/gef.py || warn "GEF download failed"
fi

dracula_pro   # again, now that bat is installed

echo "== done ($DISTRO, $PROFILE). Open a new shell."
