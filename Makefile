# dotfiles Makefile — symlink farm manager
#
# Each top-level directory (foot, mksh, kak, ...) mirrors the file
# structure that should exist inside $(HOME). E.g.:
#   foot/.config/foot/foot.ini  ->  $(HOME)/.config/foot/foot.ini
#
# `doas` is handled separately: its content (doas.conf) goes to /etc,
# so it requires privilege and is not part of the automatic `install`.
#
# Written in plain POSIX make (no GNUmake-isms like $(wildcard)/foreach)
# so it works the same with bmake and gmake.

PREFIX   = $(HOME)
DESTDIR  =
DOAS     = doas
LN       = ln -sfn
ETCDIR   = /etc

# Regular packages (go into $(HOME))
PACKAGES = foot havoc kak ash profile qutebrowser tmux vis river

.PHONY: all install link unlink uninstall relink status list clean help \
	      doas-install doas-uninstall doas-diff $(PACKAGES)

all: help

help:
	@echo "make install         - symlink all user packages into $(PREFIX)"
	@echo "make uninstall       - remove the symlinks created by this Makefile"
	@echo "make relink          - uninstall + install"
	@echo "make status          - show what's linked and what's missing"
	@echo "make list            - list available packages"
	@echo "make <package>       - install a single package, e.g. make mksh"
	@echo "make doas-install    - install a root-owned copy of doas/doas.conf into /etc"
	@echo "make doas-uninstall  - remove /etc/doas.conf (only if it matches the repo copy)"
	@echo "make doas-diff       - diff /etc/doas.conf against doas/doas.conf"

list:
	@for p in $(PACKAGES) doas; do echo "$$p"; done

install: link

link: $(PACKAGES)

# Generic rule: for each package, walk its files and symlink each one
# to the corresponding destination inside $(PREFIX), creating parent
# directories as needed. Never touches existing files that aren't our
# own symlinks (avoids accidentally overwriting real configs).
$(PACKAGES):
	@test -d "$@" || { echo "==> package '$@' does not exist, skipping"; exit 0; }
	@echo "==> linking $@"
	@cd "$@" && find . -type f | while read -r f; do \
	  rel=$${f#./}; \
	  target="$(DESTDIR)$(PREFIX)/$$rel"; \
	  src="$$(pwd)/$$rel"; \
	  mkdir -p "$$(dirname "$$target")"; \
	  if [ -e "$$target" ] && [ ! -L "$$target" ]; then \
	    echo "    SKIP (real file already exists): $$target"; \
	  elif [ -L "$$target" ] && [ "$$(readlink "$$target")" = "$$src" ]; then \
	    : ; \
	  else \
	    $(LN) "$$src" "$$target"; \
	    echo "    $$target -> $$src"; \
	  fi; \
	done

uninstall: unlink
unlink:
	@for p in $(PACKAGES); do \
	  test -d "$$p" || continue; \
	  echo "==> unlinking $$p"; \
	  (cd "$$p" && find . -type f | while read -r f; do \
	    rel=$${f#./}; \
	    target="$(DESTDIR)$(PREFIX)/$$rel"; \
	    src="$$(pwd)/$$rel"; \
	    if [ -L "$$target" ] && [ "$$(readlink "$$target")" = "$$src" ]; then \
	      rm -v "$$target"; \
	    fi; \
	  done); \
	done

relink: unlink link

# Show current state: linked, missing, or conflicting
status:
	@for p in $(PACKAGES); do \
	  test -d "$$p" || continue; \
	  (cd "$$p" && find . -type f | while read -r f; do \
	    rel=$${f#./}; \
	    target="$(DESTDIR)$(PREFIX)/$$rel"; \
	    src="$$(pwd)/$$rel"; \
	    if [ -L "$$target" ] && [ "$$(readlink "$$target")" = "$$src" ]; then \
	      echo "OK       $$target"; \
	    elif [ -e "$$target" ]; then \
	      echo "CONFLICT $$target"; \
	    else \
	      echo "MISSING  $$target"; \
	    fi; \
	  done); \
	done

# doas.conf lives in /etc, so we use doas to escalate privilege.
# Left out of `install` on purpose: you run this manually.
#
# IMPORTANT: unlike the other packages, this is NOT a symlink. doas
# refuses to load a config file that isn't owned by root with no
# group/other write bit (checked on the resolved file, so a symlink to
# something in your home directory fails with "not owned by root").
# That's intentional: trusting a user-writable doas.conf would be a
# privilege-escalation hole. So we install a root-owned COPY instead,
# and you re-run `doas-install` whenever you edit doas/doas.conf in
# the repo to push the change live.
#
# Bootstrap: if /etc/doas.conf doesn't exist yet, doas refuses to run
# ANYTHING (chicken and egg, and intentional). In that case we fall
# back to `su` just for this first time; after that doas works
# normally and doas-install/doas-uninstall work without su.
doas-install:
	@test -f doas/doas.conf || { echo "doas/doas.conf not found"; exit 1; }
	@if [ -e "$(ETCDIR)/doas.conf" ]; then \
	  echo "==> installing $(ETCDIR)/doas.conf via doas (root-owned copy)"; \
	  $(DOAS) install -o root -g root -m 0644 "$$(pwd)/doas/doas.conf" "$(ETCDIR)/doas.conf"; \
	else \
	  echo "==> $(ETCDIR)/doas.conf doesn't exist yet, doas can't self-bootstrap"; \
	  echo "==> using su for the initial bootstrap"; \
	  su -c "install -o root -g root -m 0644 \"$$(pwd)/doas/doas.conf\" \"$(ETCDIR)/doas.conf\""; \
	fi

doas-diff:
	@$(DOAS) diff -u "$(ETCDIR)/doas.conf" doas/doas.conf || true

doas-uninstall:
	@if [ -e "$(ETCDIR)/doas.conf" ] && cmp -s "$(ETCDIR)/doas.conf" doas/doas.conf; then \
	  $(DOAS) rm -v "$(ETCDIR)/doas.conf"; \
	else \
	  echo "$(ETCDIR)/doas.conf differs from doas/doas.conf (or doesn't exist), leaving it alone"; \
	  echo "run 'make doas-diff' to see what's different"; \
	fi

# Remove broken symlinks inside $(PREFIX) that point back into this repo
clean:
	@echo "==> looking for broken symlinks originating from this repo in $(PREFIX)"
	@find "$(PREFIX)" -maxdepth 4 -xtype l 2>/dev/null | while read -r l; do \
	  case "$$(readlink "$$l")" in \
	    "$$(pwd)"/*) echo "    removing broken link: $$l"; rm -v "$$l" ;; \
	  esac; \
	done
