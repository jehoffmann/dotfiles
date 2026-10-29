# dotfiles

Shell, terminal and editor setup for macOS and Linux – desktops, servers and
Proxmox guests. One repository, one installer, the same experience everywhere,
with heavier tooling only where it makes sense.

| Area | Tooling |
|---|---|
| Shell | zsh + [antidote](https://antidote.sh) (Oh My Zsh plugins via `use-omz`), bash as fallback |
| Prompt | [starship](https://starship.rs) (Dracula palette), plain prompt fallback |
| Runtimes | [mise](https://mise.jdx.dev) – Go, Rust, Node, Python, language servers |
| CLI tools | ripgrep, fd, bat, eza, fzf, zoxide, delta, lazygit, btop, jq |
| Multiplexer | tmux + TPM, `dracula/tmux` status line |
| Editor | Vim + vim-plug, coc.nvim (LSP), Dracula colour scheme |
| Debugging | gdb + [GEF](https://github.com/hugsy/gef), lldb + lldbinit.py |
| Theme | Dracula everywhere; Dracula PRO when a licence is installed locally |

## Supported platforms

| Platform | Package manager | Typical profile | Notes |
|---|---|---|---|
| macOS (Apple Silicon / Intel) | Homebrew (`Brewfile`) | desktop | |
| Ubuntu 20.04, 22.04, 24.04+ | apt | desktop or server | tested on 20.04 and 24.04 |
| Debian 12+ / Proxmox VE | apt | server | |
| Fedora 40+ | dnf | desktop or server | |
| Arch Linux | pacman | desktop or server | |
| Alpine 3.20+ | apk | server | headless Proxmox guests; installer bootstraps bash |

Tools a distribution does not package – or only in a version that is too old –
are installed through mise instead (see [Gap filling](#gap-filling-on-linux)).

## Install

Every block below can be copied as a whole into a terminal.

### New machine – macOS or Linux desktop

```sh
git clone git@github.com:jehoffmann/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
exec zsh -l
vim +PlugInstall +qa
```

Then set the terminal font to **JetBrainsMono NFM** (see [Fonts](#fonts)).
On a licensed machine, copy Dracula PRO to `~/.local/share/dracula-pro/` and run
`./install.sh --links` once more (see [Theme](#theme-dracula-and-dracula-pro)).

### New machine – Linux server (Ubuntu, Debian/Proxmox, Fedora, Arch)

```sh
git clone https://github.com/jehoffmann/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh --profile server
exec zsh -l
```

HTTPS clone, so no SSH key is needed on the server. Needs `sudo` (or root) for
the package manager.

### New machine – Alpine guest

```sh
apk add git            # as root, or: doas apk add git
git clone https://github.com/jehoffmann/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh --profile server
exec zsh -l
```

Plain `sh` is fine – the installer installs bash and re-executes itself.

### Existing machine with the old setup (Antigen, `master` branch)

```sh
cd ~/.dotfiles
git stash -u                         # keeps local changes, if any
git fetch origin --prune
git checkout -B main origin/main     # master no longer exists
git branch -D master 2>/dev/null
./install.sh                         # servers: ./install.sh --profile server
exec zsh -l
vim +PlugInstall +qa
./install.sh --cleanup               # review what would be removed …
./install.sh --cleanup --yes         # … and remove it
```

Files in the way of a symlink are moved aside as `<name>.orig-<timestamp>`.
Check `git stash list` afterwards; most old local changes are already part of
the new setup.

### Update a machine that is already on `main`

```sh
cd ~/.dotfiles
git pull --ff-only
./install.sh --links
mise install
exec zsh -l
```

Run the full `./install.sh` instead of `--links` when the Brewfile or the
package lists changed. Optional: `vim +PlugUpdate +qa`, `mise upgrade`,
`antidote update`.

### Options

```text
./install.sh                     links + packages + tools, profile auto-detected
./install.sh --profile server    headless: shell/CLI tools only, no language runtimes
./install.sh --profile desktop   adds runtimes (mise), Nerd Font, clipboard tools
./install.sh --links             only (re)create the symlinks
./install.sh --cleanup [--yes]   list leftovers of older setups; --yes deletes them
```

### Profiles

| | desktop | server |
|---|---|---|
| zsh, starship, tmux, vim, CLI tools | ✓ | ✓ |
| Language runtimes + servers (`config/mise/conf.d/20-dev.toml`) | ✓ | – |
| coc.nvim, vimspector (need Node / recent Vim) | ✓ | only if Node is present |
| Nerd Font, clipboard tools (xclip, wl-clipboard), gdb, ctags | ✓ (Linux) | – |
| `environment.d` for GUI apps | ✓ (Linux) | – |

The profile is auto-detected (macOS → desktop, Alpine → server, Linux with a
graphical target or `$DISPLAY`/`$WAYLAND_DISPLAY` → desktop, otherwise server)
and remembered in `~/.config/dotfiles/profile`. Pass `--profile` to change it.

## What goes where

Everything is a symlink into this repository, following the XDG base
directories wherever the tool supports them.

| Repository | Target |
|---|---|
| `.zshrc`, `.zprofile`, `.zshrc_<os>`, `.zsh_plugins.txt` | `~/` |
| `.bashrc`, `.bash_profile`, `.bashrc_<os>` | `~/` |
| `.aliases` (shared by zsh and bash) | `~/` |
| `.gitconfig`, `.gitignore`, `.tigrc`, `.vimrc`, `.ripgreprc`, `.editorconfig` | `~/` |
| `config/shell/env.sh` | `~/.config/shell/env.sh` |
| `config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` (plugins in `~/.config/tmux/plugins`) |
| `config/mise/config.toml`, `config/mise/conf.d/20-dev.toml` | `~/.config/mise/` |
| `config/git/gitconfig_user.template` | copied once to `~/.gitconfig_user` (not a link, see [Git](#git)) |
| `config/coc/coc-settings.json` | `~/.config/coc/` |
| `config/gdb/gdbinit` | `~/.config/gdb/gdbinit` |
| `config/lldb/lldbinit`, `lldbinit.py` | `~/.config/lldb/`, plus `~/.lldbinit` (lldb has no XDG support) |
| `config/environment.d/10-dotfiles.conf` | `~/.config/environment.d/` (Linux desktop) |
| `starship.toml`, `bat/config`, `procs/config.toml` | `~/.config/…` |
| `Brewfile` | used by the installer on macOS |
| `bin/dracula-pro-setup` | run by the installer when Dracula PRO is installed |

Runtime data also follows XDG: `RUSTUP_HOME`, `CARGO_HOME` and `GOPATH` live in
`~/.local/share/{rustup,cargo,go}`, the gdb history in `~/.local/state/gdb`.

### Local, machine-specific files (not in the repo)

| File | Purpose |
|---|---|
| `~/.zshrc_local`, `~/.bashrc_local`, `~/.zsh_aliases`, `~/.bash_aliases` | per-machine shell additions, sourced last |
| `~/.gitconfig_user` | identity, signing key, version-dependent git options (created from the template) |
| `~/.config/mise/conf.d/90-local.toml` | generated: tools missing from the distro packages |
| `~/.config/dotfiles/profile` | chosen profile |
| `~/.local/share/dracula-pro/` | licensed Dracula PRO package and its generated overrides |

## Components

### Shell

- **antidote** replaces Antigen. Plugins are listed in `.zsh_plugins.txt` and
  compiled into a static `~/.zsh_plugins.zsh`, so startup stays fast.
  `getantidote/use-omz` makes Oh My Zsh plugins work without Oh My Zsh itself.
  Platform-specific plugins use `conditional:` (`is_macos`, `is_linux`,
  `has_tmux`, `has_python`, `has_ssh_agent_linux`). Update with `antidote update`.
- **Load order** in `.zshrc`: Homebrew/Linuxbrew `shellenv` → `env.sh` →
  plugins → mise → fzf → zoxide → starship → aliases → `~/.zshrc_local`.
- **`.zprofile`** (login shells) sets up the same environment plus mise shims,
  so GUI apps and IDEs launched from the Dock see the runtimes. On Linux
  desktops `environment.d` does the same for the graphical session.
- **zoxide** replaces autojump: `z proj`, `zi` for an fzf picker.
- **fzf-tab**: Tab completion opens an fzf menu (fuzzy filter, preview) for
  files, git subcommands and branches, `kill`, `ssh` hosts, …
- **zsh-you-should-use** points out existing aliases when you type the long
  form (`git status` → `gst`); the bare `g` alias is ignored.
- **fzf**: `Ctrl-T` files, `Ctrl-R` history, `Ctrl-G` directory jump (instead of
  `Alt-C`, which clashes with the German keyboard layout on macOS). fzf ≥ 0.48
  provides the shell integration; older distro versions fall back to the
  distro's key-binding scripts.
- The OMZ `tmux` plugin is pointed at `~/.config/tmux/tmux.conf`
  (`ZSH_TMUX_CONFIG`) and does not touch `default-terminal` (`ZSH_TMUX_FIXTERM=false`).

### Runtimes with mise

`config/mise/conf.d/20-dev.toml` (desktop profile) installs Go, Rust (stable,
with `rust-analyzer` and `rust-src`), Node LTS (for coc.nvim), Python 3, `gopls`
and `ruff`. Projects pin their own versions with a `mise.toml`.

- `go install` targets `$GOPATH/bin` (`go.set_gobin = false`), so installed
  tools survive Go upgrades.
- uv uses the Python from mise and never downloads its own
  (`UV_PYTHON_PREFERENCE=only-system`, `UV_PYTHON_DOWNLOADS=never`).
- `PIP_REQUIRE_VIRTUALENV=true` prevents accidental global `pip install`.

```sh
mise ls            # what is installed and active
mise upgrade       # update everything
mise use go@1.23   # pin a version in the current project
```

Adding tools: for all desktops edit `config/mise/conf.d/20-dev.toml` in the
repo; for one machine only use
`mise use --path ~/.config/mise/conf.d/90-local.toml <tool>`. Avoid
`mise use -g` – it writes to `~/.config/mise/config.toml`, which is a symlink
into this repository.

### Gap filling on Linux

The installer tries the distribution's packages first. Whatever is missing –
for example `eza`, `zoxide`, `delta` or `starship` on Ubuntu 20.04, `lazygit` on
Fedora, or an fzf older than 0.48 – is written to
`~/.config/mise/conf.d/90-local.toml` and installed by mise. That file is local
to the machine and not part of the repository.

### tmux

- Prefix `Ctrl-a`, windows and panes start at 1, vi copy mode, mouse on,
  `prefix r` reloads the configuration.
- Plugins: tmux-sensible, tmux-pain-control, `dracula/tmux`,
  vim-tmux-navigator, tmux-resurrect (incl. vim sessions), tmux-continuum
  (automatic restore), tmux-yank.
- TPM bootstraps itself and installs missing plugins on every start, including
  plugins newly added to the configuration.
- Features of newer tmux versions sit in `%if "#{>=:#{version},…}"` blocks
  of the same file: true colour and extended keys (3.2), passthrough (3.3),
  hyperlinks (3.4); older versions get `Tc` for true colour. tmux < 3.1
  (Ubuntu 20.04) does not read
  `~/.config/tmux`, so the installer additionally links `~/.tmux.conf`.
- `set-clipboard on`: copying inside tmux reaches the local clipboard even over
  SSH, provided the local terminal supports OSC 52 (Ghostty, iTerm2, kitty,
  WezTerm – not Terminal.app).

### Vim

- Language plugins load only for their filetype (`'for'`): C/C++, Kotlin,
  Starlark (Android.bp), Go, Rust, Ruby, gtest, pytest, …
- Language servers come from `PATH` (mise, Homebrew, distro); neither coc nor
  vim-go download binaries of their own (`config/coc/coc-settings.json`).
  Python formatting and linting use ruff via coc.
- Heavy plugins only where they can run: coc.nvim needs Node and Vim ≥ 9.0.438,
  vimspector Vim ≥ 8.2.4797, vim-go Vim ≥ 8.2.5072 and Go, gutentags needs
  ctags. On a server with Ubuntu 20.04's Vim 8.1 the configuration still loads
  without errors.
- Colour scheme `dracula-pro` if the licensed package is installed, otherwise
  `dracula`.
- First start installs vim-plug and all plugins; afterwards `:PlugUpdate`,
  `:PlugClean`.

### Git

- Rebase on pull, autostash, autosquash, `rerere`, histogram diffs, moved-line
  colouring, branches sorted by recent commits, `push.autoSetupRemote`.
- Pager is delta when installed, otherwise `less`.
- Machine-specific settings live in `~/.gitconfig_user`, included at the end
  of `.gitconfig` so they override the defaults. The installer creates it once
  from `config/git/gitconfig_user.template`: interactively it asks for name,
  e-mail and the SSH public key used for signing (default: the first
  `~/.ssh/*.pub`), otherwise it takes `DOTFILES_GIT_NAME`,
  `DOTFILES_GIT_EMAIL` and `DOTFILES_GIT_SIGNINGKEY` or leaves commented
  placeholders. With a key and e-mail it also adds an entry to
  `~/.ssh/allowed_signers`, so `git log --show-signature` verifies your commits.
- At its end the file has a block between `# >>> dotfiles` markers that the
  installer rewrites on every run for the installed git version – options
  older git rejects (git 2.25 on Ubuntu 20.04 aborts on them):
  - git ≥ 2.34: SSH signing (`gpg.format = ssh`, `allowedSignersFile`),
    `help.autocorrect = prompt`
  - git ≥ 2.35: `merge.conflictstyle = zdiff3` (otherwise `diff3`)

  Everything outside the block is yours and never touched again.
- Repositories under `~/Developer/work/` additionally include
  `~/Developer/work/.gitconfig`.
- Signing is per command (`git cs`, `git css`) unless you enable
  `commit.gpgsign` in `~/.gitconfig_user`.

### Debugging and reverse engineering

Plain `gdb` and `lldb` only load harmless defaults (Intel syntax, history, pretty
printing), so IDE debugging in CLion or VS Code is unaffected. Reverse
engineering extensions are loaded on demand:

| Command | Loads |
|---|---|
| `gef` | gdb with GEF |
| `gef-multi` | `gdb-multiarch` with GEF (embedded / cross targets) |
| `lldb-re` | lldb with lldbinit.py |

GEF lives in `~/.local/share/gef/gef.py` (downloaded where gdb exists; there is
no gdb on Apple Silicon), its settings in `~/.config/gef/gef.rc`.

### Theme: Dracula and Dracula PRO

All tools use the free Dracula theme by default: starship palette, bat,
`dracula/tmux`, `dracula/vim`.

[Dracula PRO](https://draculatheme.com/pro) is licensed and **must not be
committed** to this public repository. To use it on a licensed machine (the
licence covers three computers):

1. Copy `themes/`, `design/`, `license.md` and `readme.md` from the downloaded
   package to `~/.local/share/dracula-pro/`.
2. Run `./install.sh --links` (or `bin/dracula-pro-setup [pro|blade|buffy|lincoln|morbius]`).

The setup script reads the colours from the local `design/palette.md` and
generates `~/.local/share/dracula-pro/generated/` with the tmux colours and a
starship config using the PRO palette (`STARSHIP_CONFIG` and `BAT_THEME` are set
in `env.sh` when it exists). It links the PRO tmTheme for bat/delta and, on
macOS, imports the Terminal.app profile, sets it as default and switches its
font to JetBrainsMono NFM. Vim picks up `colorscheme dracula-pro` from the
package directly; the PRO airline theme is reached through a small shim in
`config/vim/autoload/airline/themes/dracula_pro.vim` (its own file name is not
resolvable by airline).

### Fonts

The prompt, eza and the tmux status line use Nerd Font icons. Configure the
terminal font, not the shell:

- macOS: `font-jetbrains-mono-nerd-font` from the Brewfile; in Terminal.app
  choose **JetBrainsMono NFM** (Nerd Fonts now abbreviate their names:
  `NF` = icons may be wider than one cell, `NFM` = mono, every icon one cell –
  best for Terminal.app/iTerm2/tmux, `NFP` = proportional, `NL` = no ligatures).
- Linux desktop: the installer puts JetBrainsMono Nerd Font into
  `~/.local/share/fonts` (Arch: `ttf-jetbrains-mono-nerd`).
- Servers: nothing to do – your local terminal renders the glyphs.
- Ghostty bundles the Nerd Font symbols and works with any font.

## Cleaning up leftovers

The installer never deletes anything on its own: files in the way of a symlink
are moved aside as `<name>.orig-<timestamp>`. Leftovers of older setups are
removed with a separate, explicit step:

```sh
./install.sh --cleanup          # dry run: shows what would be removed
./install.sh --cleanup --yes    # removes it
```

| Path | Rule |
|---|---|
| `~/.antigen` | removed (replaced by antidote) |
| `~/.lldb` | removed (old lldbinit download) |
| `~/.tmux` | `resurrect/` is moved to `~/.local/share/tmux/resurrect` first (where tmux-resurrect looks once `~/.tmux` is gone), then removed; kept if both locations exist |
| `~/.cargo`, `~/.rustup` | removed when Rust lives under XDG – `~/.cargo` is kept if it holds tools from `cargo install` |
| `~/go` | removed when `GOPATH` is under XDG – kept if `bin/` is not empty (check and delete by hand) |
| `*.orig-<timestamp>` in `~` and `~/.config` | removed (backups made by the installer) |
| dangling symlinks in `~` / `~/.config` | removed only if they point into this repository |

Only these fixed paths below `$HOME` are ever touched.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Icons show as `?` or boxes | Terminal font is not a Nerd Font – see [Fonts](#fonts). |
| tmux looks like the default (green bar) | Plugins missing: start tmux once more or press `prefix I`. Check `~/.config/tmux/plugins`. |
| tmux ignores the configuration | Check `tmux -V`; below 3.1 `~/.tmux.conf` must link to `config/tmux/tmux.conf` (`./install.sh --links`). |
| `less` warns "terminal is not fully functional" in tmux | Missing `tmux-256color` terminfo: `infocmp -x tmux-256color \| tic -x -` (macOS), or install `ncurses-term` / `ncurses-terminfo`. |
| `git` complains about `zdiff3`, `autocorrect` or `gpg.format` | git was downgraded or the file was copied from another machine – rerun `./install.sh --links` to rewrite the managed block. |
| Commits show "Please tell me who you are" | Fill in `user.name` / `user.email` in `~/.gitconfig_user`. |
| Runtimes missing in an IDE | Restart the IDE after the first install; on Linux log out and back in (`environment.d`). |
| `mise install` failed | Needs network access to GitHub releases; rerun `mise install`. |
| zsh warns about the ssh-agent plugin | The plugin only loads on Linux when `ssh-agent` exists; install `openssh-client`. |

## Changes in the 2026 modernisation

Antigen-based setup → current tooling, in this order:

1. **Shell** – antidote + use-omz instead of the unmaintained Antigen; starship
   initialised directly; mise replaces asdf/rbenv; zoxide replaces autojump;
   Homebrew `shellenv` before any tool checks (fixes Apple Silicon); no
   installers at shell start; plain-prompt fallback for servers.
2. **Installer** – rewritten, idempotent, Brewfile on macOS, existing files
   backed up; legacy Gdbinit replaced by GEF; obsolete `.gdbinit` and
   `.p10k.zsh` removed.
3. **Runtimes** – mise for Go/Rust/Node/Python plus language servers;
   `RUSTUP_HOME`, `CARGO_HOME`, `GOPATH` under XDG; uv bound to mise Pythons;
   `.zprofile` with mise shims for GUI apps.
4. **Vim** – lazy, filetype-based plugin loading; coc/vim-go/rust use tools from
   PATH instead of downloading their own; black/flake8 replaced by ruff.
5. **tmux** – XDG location, modern terminal features, TPM auto-install, OMZ tmux
   plugin pointed at the XDG config.
6. **Theme** – Catppuccin experiment replaced by Dracula across starship, bat,
   tmux and vim, with optional local Dracula PRO.
7. **Debuggers** – XDG configs that are safe for IDEs; GEF/lldbinit via aliases.
8. **Git** – zdiff3, histogram, autoSetupRemote, sorting, editor from `$EDITOR`.
9. **Linux** – Ubuntu 20.04+, Debian/Proxmox, Fedora, Arch, Alpine;
   desktop/server profiles; gap filling via mise; version gates for tmux, git
   and Vim; Nerd Font and `environment.d` on Linux desktops.
10. **Docs** – all comments in English, this README.
11. **Cleanup** – `install.sh --cleanup` removes leftovers of the old setup
    (dry run by default).
12. **One file per tool** – tmux version differences via `%if` in
    `tmux.conf`; git identity, signing and version-dependent options in
    `~/.gitconfig_user` (template + managed block) instead of extra includes.

See `git log` for the individual commits.
