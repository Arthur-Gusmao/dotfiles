export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/bin:$PATH"

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

export EDITOR=vim
export VISUAL=vim
export TERMINAL=havoc

export BROWSER=firefox

export LANG=en_US.UTF-8
export LC_ALL=C.UTF-8

export PAGER=less
export LESS='-R --use-color'

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

export QTWEBENGINE_FORCE_USE_GBM=0

export CLICOLOR=1

export ENV="$HOME/.mkshrc"

if [ -f "$HOME/.secrets" ]; then
	. "$HOME/.secrets"
fi

if [ "$PWD" != "$HOME" ] && [ "$PWD" -ef "$HOME" ] ; then cd ; fi

if [ -x /usr/bin/resizewin ] ; then /usr/bin/resizewin -z ; fi

if [ -x /usr/bin/fortune ] ; then /usr/bin/fortune freebsd-tips ; fi
