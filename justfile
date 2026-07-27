# dotfiles justfile
#
# Each directory mirrors $HOME's structure.
# e.g.  foot/.config/foot/foot.ini  ->  ~/.config/foot/foot.ini
#
# doas/doas.conf is special: it lives in /etc and must be a root-owned
# COPY (not a symlink), so it's handled separately.

prefix := env("HOME")
doas := "doas"
etcdir := "/etc"

pkgs := "foot havoc kak profile qutebrowser tmux vis river mako gtk jj shell git swayidle"

arkenfox_url := "https://github.com/arkenfox/user.js/releases/latest/download/user.js"
firefox_dir := env("HOME") + "/.config/mozilla/firefox"
opencode_url := "https://opencode.ai/install"

# ── default ──────────────────────────────────────────────────────────

default:
    @just --list

# ── packages ─────────────────────────────────────────────────────────

install *pkg:
    #!/bin/sh
    set -e
    for p in {{ pkgs }}; do
        test -d "$p" || { echo "==> $p: not found, skipping"; continue; }
        echo "==> $p"
        cd "$p" && find . -type f | while read -r f; do
            rel="${f#./}"
            dest="{{ prefix }}/$rel"
            src="$(pwd)/$rel"
            mkdir -p "$(dirname "$dest")"
            if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
                continue
            elif [ -e "$dest" ]; then
                echo "    SKIP (exists): $dest"
            else
                ln -sfn "$src" "$dest"
                echo "    $dest -> $src"
            fi
        done
        cd ..
    done

uninstall:
    #!/bin/sh
    set -e
    for p in {{ pkgs }}; do
        test -d "$p" || continue
        echo "==> $p"
        (cd "$p" && find . -type f | while read -r f; do
            rel="${f#./}"
            dest="{{ prefix }}/$rel"
            src="$(pwd)/$rel"
            if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
                rm -v "$dest"
            fi
        done)
    done

relink: uninstall install

status:
    #!/bin/sh
    for p in {{ pkgs }}; do
        test -d "$p" || continue
        (cd "$p" && find . -type f | while read -r f; do
            rel="${f#./}"
            dest="{{ prefix }}/$rel"
            src="$(pwd)/$rel"
            if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
                printf '  \033[32mOK\033[0m       %s\n' "$dest"
            elif [ -e "$dest" ]; then
                printf '  \033[31mCONFLICT\033[0m %s\n' "$dest"
            else
                printf '  \033[33mMISSING\033[0m  %s\n' "$dest"
            fi
        done)
    done

list:
    @echo "{{ pkgs }}" | tr ' ' '\n'

# ── arkenfox user.js ────────────────────────────────────────────────

arkenfox:
    #!/bin/sh
    set -e
    echo "==> downloading arkenfox user.js"
    curl -sL "{{ arkenfox_url }}" -o /tmp/user.js || { echo "failed to download user.js"; exit 1; }
    profiles=$(find "{{ firefox_dir }}" -maxdepth 1 -type d -name '*.default*' 2>/dev/null)
    if [ -z "$profiles" ]; then
        echo "    no Firefox profiles found in {{ firefox_dir }}"
        echo "    start Firefox once to create a profile, then re-run 'just arkenfox'"
        rm -f /tmp/user.js
        exit 0
    fi
    for d in $profiles; do
        cp /tmp/user.js "$d/user.js"
        echo "    $d/user.js"
    done
    rm -f /tmp/user.js
    echo "    restart Firefox to apply"

# ── opencode ─────────────────────────────────────────────────────────

opencode:
    #!/bin/sh
    set -e
    echo "==> installing opencode"
    curl -fsSL "{{ opencode_url }}" | bash

# ── doas (needs root) ───────────────────────────────────────────────

doas-install:
    #!/bin/sh
    set -e
    test -f doas/doas.conf || { echo "doas/doas.conf not found"; exit 1; }
    echo "==> {{ etcdir }}/doas.conf"
    if [ -e "{{ etcdir }}/doas.conf" ]; then
        {{ doas }} install -o root -g root -m 0644 \
            "$(pwd)/doas/doas.conf" "{{ etcdir }}/doas.conf"
    else
        echo "    bootstrapping (no doas yet, using su)"
        su -c "install -o root -g root -m 0644 \
            '$(pwd)/doas/doas.conf' '{{ etcdir }}/doas.conf'"
    fi

doas-uninstall:
    #!/bin/sh
    if [ -e "{{ etcdir }}/doas.conf" ] && cmp -s "{{ etcdir }}/doas.conf" doas/doas.conf; then
        {{ doas }} rm -v "{{ etcdir }}/doas.conf"
    else
        echo "{{ etcdir }}/doas.conf differs or doesn't exist; run 'just doas-diff'"
    fi

doas-diff:
    {{ doas }} diff -u "{{ etcdir }}/doas.conf" doas/doas.conf || true

# ── cleanup ──────────────────────────────────────────────────────────

clean:
    #!/bin/sh
    find "{{ prefix }}" -maxdepth 4 -type l ! -exec test -e {} \; -print 2>/dev/null | \
    while read -r l; do
        case "$l" in
            "{{ prefix }}/.config/opencode"*) ;;
            *) case "$(readlink "$l")" in
                "$(pwd)"/*) echo "rm $l"; rm "$l" ;;
            esac ;;
        esac
    done
