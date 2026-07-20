# ~/.profile

# ------------------------------------------------------------------------------
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

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

# ------------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# ------------------------------------------------------------------------------
export EDITOR=vis
export VISUAL=vis
export ABDUCO_CMD=mtm
export TERMINAL=havoc
export BROWSER=firefox
export PAGER=less
export LESS='-R'
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

# ------------------------------------------------------------------------------
export LC_ALL=C.UTF-8
export QTWEBENGINE_FORCE_USE_GBM=0
export CLICOLOR=1

# ------------------------------------------------------------------------------
export ENV="$HOME/.rc"

# ------------------------------------------------------------------------------
if [ -f "$HOME/.secrets" ]; then
    . "$HOME/.secrets"
fi

# ------------------------------------------------------------------------------
if [ "$PWD" != "$HOME" ] && [ "$PWD" -ef "$HOME" ]; then
    cd
fi

# ------------------------------------------------------------------------------
case "$-" in
    *i*)
        [ -x /usr/bin/resizewin ] && /usr/bin/resizewin -z
        [ -x /usr/bin/fortune ] && /usr/bin/fortune freebsd-tips
        ;;
esac
