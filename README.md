# dotfiles

Personal configuration for a small, direct, text-oriented environment.

## Principles

- **Plain files** — configuration is ordinary files, no generators or templates
- **POSIX shell** — scripts use `#!/bin/sh`, `set -eu`, stdin/stdout
- **No bashisms** — avoid GNU extensions when POSIX is enough
- **Machine-local** — differences are few, local, and explicit
- **Wayland optional** — river, foot, mako don't define the shell/editor/terminal in a TTY or over SSH

## Layout

Each package directory mirrors its destination under `$HOME`:

```
foot/.config/foot/foot.ini  ~/.config/foot/foot.ini
river/.config/river/init    ~/.config/river/init
shell/.rc                   ~/.rc
```

`doas/doas.conf` is the exception: installed as a root-owned **copy** at
`/etc/doas.conf`, never a symlink.

## Quick start

```sh
git clone <url> ~/.dotfiles
cd ~/.dotfiles
doas make deps       # install system packages
make install         # symlink everything into $HOME
```

## Architecture

Core symlink operations live in a single POSIX `sh` script:

```
bin/dotfiles   →  CLI: install, status, uninstall, list, relink, clean
```

The Makefile is a thin wrapper around it, adding only system-level
orchestration (package installation, doas/local.d management, Firefox
user.js deployment).

Packages are auto-discovered: any directory at the repo root that contains
files is a package. No need to register new ones.

## Usage

| Command | Description |
|---------|-------------|
| `make install` | Symlink all packages into `$HOME` |
| `make foot` | Install one package |
| `make uninstall` | Remove our symlinks |
| `make relink` | Uninstall + install |
| `make status` | Show link state (✓ / ✗ / ⚠) |
| `make list` | List available packages |
| `make clean` | Remove broken symlinks from `$HOME` |
| `make deps` | Install required packages via detected PM |
| `make bootstrap` | deps + install (full setup) |
| `make update` | `git pull --ff-only` + relink |
| `make system-install` | Install `/etc/doas.conf` + `/etc/local.d/*` |
| `make arkenfox` | Deploy arkenfox user.js to Firefox profiles |
| `make opencode` | Install opencode |

Or invoke `bin/dotfiles` directly:

```
bin/dotfiles install         →  symlink all packages
bin/dotfiles install foot    →  install specific package
bin/dotfiles status          →  show link state
bin/dotfiles clean           →  remove broken symlinks
```

Installation never overwrites existing files — resolve conflicts manually.
`uninstall` only removes links pointing exactly at this repository.

## Package manager detection

`make deps` auto-detects the distro and installs packages:

| Detected | Manager | Command |
|----------|---------|---------|
| `apk` | Alpine | `doas apk add` |
| `apt-get` | Debian/Ubuntu | `doas apt install -y` |
| `pacman` | Arch | `doas pacman -S --needed` |
| `dnf` | Fedora | `doas dnf install -y` |
| `zypper` | openSUSE | `doas zypper install -n` |
| `xbps-install` | Void | `doas xbps-install -S` |
| `emerge` | Gentoo | `doas emerge -n` |
| `brew` | Homebrew | `brew install` |
| `nix` | Nix | `nix profile install` |
| `guix` | Guix | `guix install` |
| `pkg` | FreeBSD | `doas pkg install -y` |
| `pkg_add` | OpenBSD | `doas pkg_add` |

Privilege escalation auto-detects `doas` → `sudo`. Package managers that
don't need root (brew, nix, guix) skip escalation entirely.

> **Note**: `doas` cannot authenticate inside `make`/`bmake` recipes
> (background process group blocks terminal access). Run `doas make deps`
> to authenticate from the real terminal.

## Direction

The goal is to reduce the Makefile to a simple POSIX `sh` bootstrap and let
`bin/dotfiles` handle everything.

When adding something, prefer a small readable script over another automation
layer. If a tool is specific to Linux or Wayland, make that clear in its name,
directory, and documentation.
