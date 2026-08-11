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
for d in "$HOME/.local/bin" "$HOME/.opencode/bin" "$HOME/bin" "$HOME/.local/share/cargo/bin"; do
    case ":$PATH:" in
        *":$d:"*) ;;
        *) export PATH="$d:$PATH" ;;
    esac
done

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

if test -z "${XDG_RUNTIME_DIR}"; then
    export XDG_RUNTIME_DIR="/run/user/$(id -ru)"
fi
if test -d "$XDG_RUNTIME_DIR"; then
  perms="$(stat -c '%a %u' "${XDG_RUNTIME_DIR}")"
  if [ "${perms}" != "700 $(id -ru)" ]; then
    unset XDG_RUNTIME_DIR
    echo "WARNING! XDG_RUNTIME_DIR has incorrect permissions"
  fi
else
  mkdir -p "${XDG_RUNTIME_DIR}"
  chmod 0700 "${XDG_RUNTIME_DIR}"
fi

export CC=cc
export CFLAGS="-O2 -pipe"
command -v nproc >/dev/null 2>&1 && export MAKEFLAGS="-j$(nproc)"

export NINJA_STATUS="[36;1m[%e (s): %s/%t][0m "

# ─── default programs ────────────────────────────────────────────────
export EDITOR=kak
export VISUAL=kak
export FCEDIT=kak
export TERMINAL=foot
export BROWSER=librewolf
export PAGER=less
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

# ─── secrets (unversioned) ───────────────────────────────────────────
[ -f "$HOME/.secrets" ] && . "$HOME/.secrets"
