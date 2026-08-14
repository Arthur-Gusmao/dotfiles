#!/bin/sh

# ─── path / toolchain ────────────────────────────────────────────────
# This MUST come first: yash never reads /etc/profile, and its [ / test /
# echo / printf built-ins are substitutive (they need the external binary
# on PATH). With an empty PATH (bare login) they fail, so establish the
# baseline using only case/export/parameter expansion.
case ":$PATH:" in
    *":/usr/sbin:"*) ;;
    *) export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin${PATH:+:$PATH}" ;;
esac
PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.opencode/bin:$HOME/bin:$HOME/.local/share/cargo/bin:$PATH"
export PATH

# ─── plan9port ───────────────────────────────────────────────────────
# Append (never prepend) so coreutils win; use `9` for plan9 versions.
if [ -d /usr/lib/plan9/bin ]; then
    export PLAN9=/usr/lib/plan9
    case ":$PATH:" in
        *":/usr/lib/plan9/bin:"*) ;;
        *) PATH="$PATH:/usr/lib/plan9/bin" ;;
    esac
fi

# ─── locale ──────────────────────────────────────────────────────────
# /etc/profile.d/20locale.sh is skipped too
export LANG=${LANG:-C.UTF-8}
export LC_COLLATE=${LC_COLLATE:-C}

# ─── XDG base dirs ───────────────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS="$XDG_DATA_HOME/flatpak/exports/share:/var/lib/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_CONFIG_DIRS="/etc/xdg"
mkdir -p "$XDG_STATE_HOME/less"

if [ -z "${XDG_RUNTIME_DIR}" ]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -ru)"
fi
mkdir -p "${XDG_RUNTIME_DIR}" 2>/dev/null
chmod 0700 "${XDG_RUNTIME_DIR}" 2>/dev/null

export CC=cc
export CFLAGS="-O2 -pipe"
command -v nproc >/dev/null 2>&1 && export MAKEFLAGS="-j$(nproc)"

# ─── default programs ────────────────────────────────────────────────
# Plumb files instead of starting new editor.
export EDITOR=E
unset FCEDIT VISUAL

# Get rid of backspace characters in Unix man output.
#PAGER=nobs

# Equivalent variables for rc(1).
home=$HOME
prompt="$H=;          "
user=$USER

#export VISUAL=kak
#export FCEDIT=kak
export TERMINAL=foot
export BROWSER=librewolf
export PAGER=nobs
export MANPAGER="$PAGER"

# ─── pager / history ─────────────────────────────────────────────────
export LESS='-MSFR'
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export HISTSIZE=2047

# ─── git ─────────────────────────────────────────────────────────────
export GIT_SSH=dbclient

# ─── tool XDG cleanup ────────────────────────────────────────────────
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# ─── session / wayland ───────────────────────────────────────────────
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export QTWEBENGINE_FORCE_USE_GBM=0
export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export GDK_BACKEND=wayland

# ─── cursor theme ──────────────────────────────────────────────────
# wlroots (zrwm), Qt, and XWayland all read XCURSOR_THEME; GTK reads
# gtk-cursor-theme-name from settings.ini.
export XCURSOR_THEME=plan9
export XCURSOR_SIZE=24

# ─── secrets (unversioned) ───────────────────────────────────────────
[ -f "$HOME/.secrets" ] && . "$HOME/.secrets"
