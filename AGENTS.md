# dotfiles — AGENTS.md

## Build system

- **`make` (GNU Make 4.4) and `bmake`** both supported. Constraints for bmake:
  - NO `!=` assignments (use `$$(pwd)` in recipes instead)
  - NO `$(shell ...)` (inline shell logic inside recipes instead)
  - NO computed variable names (use shell `case` inside recipes)
- **`.PHONY`** must list every target explicitly.

## `make deps` / package installation

- **`doas`/`sudo` cannot authenticate inside recipes** (background process group blocks terminal access). Instead, detect non-root and print: `doas make deps`
- Any recipe that might call `doas` needs `trap '' 21 22` at the top to prevent SIGTTIN/SIGTTOU from stopping the process.
- `DEPS` variable is user-editable — set per-distro package names in Makefile.
- PM detection (apk, apt, pacman, etc.) and package manager command selection happens inside the `deps` recipe via shell `if/elif`.

## `make services` / service management

- `SERVICES` variable is user-editable — set service names in Makefile.
- Init system is auto-detected inside the recipe: OpenRC (`rc-update`), systemd (`systemctl`), runit (`sv`), s6 (`s6-svc`).
- **elogind and seatd conflict** on seat/session management — never enable both. Only `elogind` is in `SERVICES` by default.
- Services are enabled and started in one pass.
- `make services` needs root (prints `doas make services` when non-root).

## Directory layout

- Each subdirectory mirrors its `$HOME` path: `foot/.config/foot/foot.ini` → `~/.config/foot/foot.ini`
- `doas/doas.conf` is special: installed as a **root-owned copy** at `/etc/doas.conf` (never a symlink).
- `local.d/*` → `/etc/local.d/` (root-owned copies).
- `bin/dotfiles` → POSIX `sh` CLI script (discovered via `$PATH` or direct path).

## Style conventions

- **ANSI color codes inline**: `\033[1m` etc. No external tools (gum, lolcat, pastel).
- **Emoji approved in output**: ✓ ✗ ⚠ ─── for status indicators.
- **Shell scripts**: `#!/bin/sh`, `set -eu`, stdin/stdout pipes. No bashisms.
- **No RC files** (no `.bashrc`, `.zshrc`). The `shell/` package provides `.rc` that shell init files source.
- **Wayland is optional**: river, foot, mako do not define the shell/editor/terminal in a TTY or over SSH.

## Architecture

- **Core logic** lives in `bin/dotfiles` (POSIX `sh`, `set -eu`). Handles: install, uninstall, status, list, relink, clean.
- **Packages are auto-discovered** — any directory at repo root with files is a package. System dirs (`.git`, `doas`, `local.d`, `bin`) are excluded.
- **`make`** is a thin wrapper: core targets call `bin/dotfiles $@`. System/orchestration targets (deps, doas, local.d, arkenfox, opencode) stay in Makefile.
- The script uses a temp file (`/tmp/.dotfiles-$$`) to avoid the `find | while` subshell variable scoping issue. Both files are cleaned up after use.
- Color variables are initialized to empty and overwritten with ANSI codes only when stdout is a TTY (`[ -t 1 ]`). This strips colors when piped.

## Targets

| Command | Purpose |
|---------|---------|
| `make install` | Symlink all packages into `$HOME` |
| `make uninstall` | Remove only our symlinks |
| `make status` | Show link state (OK/CONFLICT/MISSING) per file |
| `make <pkg>` | Install one package (e.g. `make foot`) |
| `make list` | List available packages |
| `make relink` | Uninstall + install |
| `make deps` | Print or install required packages (run as `doas make deps`) |
| `make services` | Enable standard services (run as `doas make services`) |
| `make services-list` | List configured services |
| `make bootstrap` | deps + install + services |
| `make update` | `git pull --ff-only` + relink |
| `make system-install` | Install `/etc/doas.conf` + `/etc/local.d/*` |
| `make clean` | Remove broken symlinks from `$HOME` |
| `make arkenfox` | Deploy arkenfox user.js to Firefox profiles |
| `make opencode` | Install opencode via curl pipe |
| `make zrwm-build` | Build & install zrwm from source (river 0.4 WM) |

## river / zrwm

- **river-classic** was replaced by **river (0.4.x) + zrwm** (window manager).
- `river` package from Alpine community repo (compositor only, no riverctl).
- `zrwm` built from source (`git.sr.ht/~zuki/zrwm`) — written in C, uses `zrwm-msg` IPC.
- Config split:
  - `river/.config/river/init` → compositor autostarts + `exec zrwm`
  - `zrwm/.config/zrwm/init` → keybindings, layout, rules, appearance
- `river/.config/river/init.bak` preserved backup of the old river-classic config.
- Build zrwm: `doas make zrwm-build` (requires `zig`, `wayland-dev`)
