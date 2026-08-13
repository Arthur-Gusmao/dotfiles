# dotfiles

Personal configuration for a small, direct, text-oriented environment.

## Principles

- **Plain files** — configuration is ordinary files, no generators or templates
- **POSIX shell** — scripts use `#!/bin/sh`, `set -eu`, stdin/stdout
- **No bashisms** — avoid GNU extensions when POSIX is enough
- **Machine-local** — differences are few, local, and explicit
- **Wayland optional** — river, foot, fnott don't define the shell/editor/terminal in a TTY or over SSH

## Layout

Each package directory mirrors its destination under `$HOME`:

```
foot/.config/foot/foot.ini     →  ~/.config/foot/foot.ini
river/.config/river/init       →  ~/.config/river/init
profile/.profile               →  ~/.profile
shell/.config/yash/rc          →  ~/.config/yash/rc
shell/.config/yash/profile     →  ~/.config/yash/profile
localbin/.local/bin/startr     →  ~/.local/bin/startr
```

`profile/.profile` is the single POSIX login profile. yash never reads
`~/.profile` (nor `/etc/profile`) automatically (see `man yash`), so
`~/.config/yash/profile` is a shim that sources it; the interactive rc
sources it too for non-login shells.

yash startup facts worth remembering:
- Login reads `$XDG_CONFIG_HOME/yash/profile`, interactive reads `~/.config/yash/rc`.
- `[`, `test`, `echo`, `printf` are *substitutive built-ins*: they need the
  external binary on `PATH` and fail when `PATH` is empty (bare login). The
  `.profile` therefore sets the system baseline (incl. `/sbin`) **first**,
  using only `case`/`export`/parameter expansion.
- yash history format is incompatible with other shells, so `HISTFILE` lives
  at `~/.local/state/yash/history`.

`doas/doas.conf` is the exception: installed as a root-owned **copy** at
`/etc/doas.conf`, never a symlink.

## Quick start

```sh
git clone <url> ~/.dotfiles
cd ~/.dotfiles
doas bin/dotfiles deps       # install system packages
bin/dotfiles install         # symlink everything into $HOME
```

## Architecture

A single POSIX `sh` script handles everything:

```
bin/dotfiles   →  CLI: install, uninstall, status, list, relink, clean,
                  deps, services, bootstrap, update, system-install,
                  iosevka, plan9-cursor, opencode, zrwm-build
```

No Makefile, no justfile, no plan9port — zero dependencies beyond `sh`.

Packages are auto-discovered: any directory at the repo root that contains
files is a package. No need to register new ones.

## Usage

| Command | Description |
|---------|-------------|
| `bin/dotfiles install` | Symlink all packages into `$HOME` |
| `bin/dotfiles install foot` | Install one package |
| `bin/dotfiles uninstall` | Remove our symlinks |
| `bin/dotfiles relink` | Uninstall + install |
| `bin/dotfiles status` | Show link state (✓ / ✗ / ⚠) |
| `bin/dotfiles list` | List available packages |
| `bin/dotfiles clean` | Remove broken symlinks from `$HOME` |
| `bin/dotfiles deps` | Install required packages via detected PM |
| `bin/dotfiles bootstrap` | deps + install + services (full setup) |
| `bin/dotfiles update` | `git pull --ff-only` + relink |
| `bin/dotfiles services` | Enable standard services |
| `bin/dotfiles services-list` | List configured services |
| `bin/dotfiles system-install` | Install `/etc/doas.conf` + `/etc/local.d/*` |
| `bin/dotfiles iosevka` | Install Iosevka Term Nerd Font |
| `bin/dotfiles plan9-cursor` | Install plan9 cursor theme |
| `bin/dotfiles opencode` | Install opencode |
| `bin/dotfiles zrwm-build` | Build & install zrwm from source |
| `bin/dotfiles mew-build` | Build & install mew from source |

Installation never overwrites existing files — resolve conflicts manually.
`uninstall` only removes links pointing exactly at this repository.

## Package manager detection

`bin/dotfiles deps` auto-detects the distro and installs packages:

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

> **Note**: `doas` cannot authenticate inside background process groups.
> Run `doas bin/dotfiles deps` to authenticate from the real terminal.

## river / zrwm

- river (compositor) + zrwm (window manager)
- Config: `river/.config/river/init` (compositor) + `zrwm/.config/zrwm/init` (keybindings/layout)
- Build zrwm: `doas bin/dotfiles zrwm-build` (requires `zig`, `wayland-dev`)
