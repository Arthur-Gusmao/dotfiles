# ~/.profile
# ---------------------------------------------------------------------
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg"

if test -z "${XDG_RUNTIME_DIR}"; then
    export XDG_RUNTIME_DIR=/run/user/$(id -ru)
fi
if test -d "${XDG_RUNTIME_DIR}"; then
    perms="$(stat -c '%a %u' "${XDG_RUNTIME_DIR}")"
    if [ "${perms}" != "700 $(id -ru)" ]; then
        unset XDG_RUNTIME_DIR
        echo "WARNING! XDG_RUNTIME_DIR has incorrect permissions"
    fi
else
    mkdir -p "${XDG_RUNTIME_DIR}"
    chmod 0700 "${XDG_RUNTIME_DIR}"
fi

# ---------------------------------------------------------------------
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
export CC=cc
export CFLAGS="-O2 -pipe"
export MAKEFLAGS="-j$(nproc)"

# ---------------------------------------------------------------------
export EDITOR=vis
export VISUAL=vis
export ABDUCO_CMD=mtm
export TERMINAL=havoc
export BROWSER=firefox
export PAGER=less
export MANPAGER="$PAGER"

# ---------------------------------------------------------------------
export HISTSIZE=2047
export FCEDIT=vis

# ---------------------------------------------------------------------
export LESS='MSF'

# ------------------------------------------------------------------------
export MAIL="/var/mail/$(id -un)"
export MAILCHECK=600

# ------------------------------------------------------------------------
export GIT_PAGER="$PAGER"
export GIT_EDITOR="$EDITOR"
export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config"

# ---------------------------------------------------------------------
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GPG_TTY="$(tty)"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite_history"
export GDBHISTFILE="$XDG_STATE_HOME/gdb/history"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonstartup.py"
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# ---------------------------------------------------------------------
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export QTWEBENGINE_FORCE_USE_GBM=0
export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export GDK_BACKEND=wayland

# ---------------------------------------------------------------------
export LANG=C.UTF-8

# ---------------------------------------------------------------------
export CLICOLOR=1
export COLORTERM=truecolor
export GREP_COLORS='ms=01;31:mc=01;31:sl=:cx=:fn=35:ln=32:se=36'

# ---------------------------------------------------------------------
export ENV="$HOME/.rc"

# ---------------------------------------------------------------------
if [ -f "$HOME/.secrets" ]; then
    . "$HOME/.secrets"
fi

# ---------------------------------------------------------------------
case "$-" in
    *i*)
        [ -x /usr/bin/resizewin ] && /usr/bin/resizewin -z
        [ -x /usr/bin/fortune ] && /usr/bin/fortune freebsd-tips
        ;;
esac

