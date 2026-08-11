# dotfiles — AGENTS.md

## Entry point

- **`bin/dotfiles`** — POSIX `sh` script (`#!/bin/sh -e`).
- Invoked as `bin/dotfiles <command>` from repo root, or `dotfiles <command>` if `bin/` is in `$PATH`.
- Zero dependencies beyond `sh` (POSIX).

## `deps` / package installation

- **`doas`/`sudo` cannot authenticate inside background process groups** — runs detect non-root and print: `doas bin/dotfiles deps`
- Recipes that call `doas`/`su` use `trap '' 21 22` to prevent SIGTTIN/SIGTTOU.
- `DEPS` variable is user-editable — set per-distro package names in the script.
- PM detection (apk, apt, pacman, etc.) via POSIX `sh` `if/elif` chains inside `do_deps`.

## `services` / service management

- `SERVICES` variable is user-editable.
- Init system auto-detection: OpenRC (`rc-update`), systemd (`systemctl`), runit (`sv`), s6 (`s6-svc`).
- **elogind and seatd conflict** — never enable both. Only `seatd` is in `SERVICES` by default.

## Directory layout

- Each subdirectory mirrors its `$HOME` path: `foot/.config/foot/foot.ini` → `~/.config/foot/foot.ini`
- `localbin/.local/bin/*` → `~/.local/bin/*` (user scripts).
- `doas/doas.conf` → **root-owned copy** at `/etc/doas.conf` (never a symlink). `system-install` also removes `/etc/doas.d/*.conf` (Alpine doas reads drop-ins and the last matching rule wins — they can silently override the `nopass` in `doas.conf`).
- `local.d/*` → `/etc/local.d/` (root-owned copies).
- `bin/dotfiles` → CLI entry point.
- `EXCL` excludes only the repo's own `bin/` (`$repo/bin/*`) — other `bin/` dirs (e.g. `localbin/.local/bin`) are valid packages.

## Style conventions

- **ANSI color codes inline**: `\033[1m` etc. No external tools.
- **Emoji**: ✓ ✗ ⚠ ─── for status indicators.
- **POSIX sh only**: `#!/bin/sh -e`, no bashisms.
- **No RC files** (no `.bashrc`, `.zshrc`). The `shell/` package provides `~/.config/yash/{rc,profile}` for shell init.
- `~/.profile` (from `profile/`) is the single POSIX login profile. yash never reads it automatically, so `~/.config/yash/profile` is a shim that sources it. The interactive rc does NOT source it — interactive shells inherit the environment from the session (spawned from a login shell). PATH is a plain prepend, no idempotency needed.
- **Wayland is optional**: river, foot, fnott don't define the shell/editor/terminal in a TTY or over SSH.

## Architecture

- **Single `bin/dotfiles`** — POSIX `sh` handles everything: install, uninstall, status, list, relink, clean, deps, services, system-install, bootstrap, update, iosevka, opencode, zrwm-build, mew-build.
- **Packages auto-discovered** — any directory at repo root with files is a package. `.git`, `doas`, `local.d`, `bin` excluded.
- **No Makefile, no justfile, no plan9port** — pure `sh`.
- **No `find | while` subshell scoping issue** — uses `for f in $(find ...)` instead of piping into `while read`.
- Color variables initialized to empty, overwritten with ANSI codes only when `[ -t 1 ]`.

## Targets

| Command | Purpose |
|---------|---------|
| `bin/dotfiles install` | Symlink all packages into `$HOME` |
| `bin/dotfiles install foot` | Install one package |
| `bin/dotfiles uninstall` | Remove only our symlinks |
| `bin/dotfiles status` | Show link state (OK/CONFLICT/MISSING) |
| `bin/dotfiles list` | List available packages |
| `bin/dotfiles relink` | Uninstall + install |
| `bin/dotfiles deps` | Install required packages (run as `doas bin/dotfiles deps`) |
| `bin/dotfiles services` | Enable services (`doas bin/dotfiles services`) |
| `bin/dotfiles services-list` | List configured services |
| `bin/dotfiles bootstrap` | deps + install + services |
| `bin/dotfiles update` | `git pull --ff-only` + relink |
| `bin/dotfiles system-install` | Install `/etc/doas.conf` + `/etc/local.d/*` |
| `bin/dotfiles clean` | Remove broken symlinks from `$HOME` |
| `bin/dotfiles iosevka` | Install Iosevka Term Nerd Font |
| `bin/dotfiles opencode` | Install opencode via curl pipe |
| `bin/dotfiles zrwm-build` | Build & install zrwm from source |
| `bin/dotfiles mew-build` | Build & install mew from source |

## river / zrwm

- **river-classic** replaced by **river (0.4.x) + zrwm** (window manager).
- `river` from Alpine community repo (compositor only, no riverctl).
- `zrwm` from `git.sr.ht/~zuki/zrwm` — C, uses `zrwm-msg` IPC.
- Config: `river/.config/river/init` + `zrwm/.config/zrwm/init`
- Build: `doas bin/dotfiles zrwm-build` (requires `zig`, `wayland-dev`)
