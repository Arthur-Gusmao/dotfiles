# dotfiles Makefile
#
# Each directory mirrors $HOME's structure.
# e.g.  foot/.config/foot/foot.ini  ->  ~/.config/foot/foot.ini
#
# doas/doas.conf is special: it lives in /etc and must be a root-owned
# COPY (not a symlink), so it's handled separately.

PREFIX  = $(HOME)
DOAS    = doas
ETCDIR  = /etc

PKGS = foot havoc kak profile qutebrowser tmux vis river mako gtk jj shell git swayidle

.PHONY: all install uninstall relink status list help \
        doas-install doas-uninstall doas-diff clean arkenfox opencode $(PKGS)

all: help

help:
	@echo "make install       symlink all packages into $(PREFIX)"
	@echo "make uninstall     remove our symlinks"
	@echo "make relink        uninstall + install"
	@echo "make status        show linked / missing / conflict"
	@echo "make list          list available packages"
	@echo "make <pkg>         install one package (e.g. make foot)"
	@echo "make doas-install  install /etc/doas.conf (root-owned copy)"
	@echo "make doas-uninstall  remove /etc/doas.conf (only if matching)"
	@echo "make doas-diff     diff installed vs repo doas.conf"
	@echo "make arkenfox      install arkenfox user.js to Firefox profiles"
	@echo "make opencode     install opencode"
	@echo "make clean         remove broken symlinks from $(PREFIX)"

list:
	@echo $(PKGS) | tr ' ' '\n'

# ── packages ─────────────────────────────────────────────────────────

install: $(PKGS)

$(PKGS):
	@test -d "$@" || { echo "==> $@: not found, skipping"; exit 0; }
	@echo "==> $@"
	@cd "$@" && find . -type f | while read -r f; do \
	  rel=$${f#./}; \
	  dest="$(PREFIX)/$$rel"; \
	  src="$$(pwd)/$$rel"; \
	  mkdir -p "$$(dirname "$$dest")"; \
	  if [ -L "$$dest" ] && [ "$$(readlink "$$dest")" = "$$src" ]; then \
	    continue; \
	  elif [ -e "$$dest" ]; then \
	    echo "    SKIP (exists): $$dest"; \
	  else \
	    ln -sfn "$$src" "$$dest"; \
	    echo "    $$dest -> $$src"; \
	  fi; \
	done

uninstall:
	@for p in $(PKGS); do \
	  test -d "$$p" || continue; \
	  echo "==> $$p"; \
	  (cd "$$p" && find . -type f | while read -r f; do \
	    rel=$${f#./}; \
	    dest="$(PREFIX)/$$rel"; \
	    src="$$(pwd)/$$rel"; \
	    if [ -L "$$dest" ] && [ "$$(readlink "$$dest")" = "$$src" ]; then \
	      rm -v "$$dest"; \
	    fi; \
	  done); \
	done

relink:
	@$(MAKE) uninstall
	@$(MAKE) install

status:
	@for p in $(PKGS); do \
	  test -d "$$p" || continue; \
	  (cd "$$p" && find . -type f | while read -r f; do \
	    rel=$${f#./}; \
	    dest="$(PREFIX)/$$rel"; \
	    src="$$(pwd)/$$rel"; \
	    if [ -L "$$dest" ] && [ "$$(readlink "$$dest")" = "$$src" ]; then \
	      printf '  \033[32mOK\033[0m       %s\n' "$$dest"; \
	    elif [ -e "$$dest" ]; then \
	      printf '  \033[31mCONFLICT\033[0m %s\n' "$$dest"; \
	    else \
	      printf '  \033[33mMISSING\033[0m  %s\n' "$$dest"; \
	    fi; \
	  done); \
	done

# ── arkenfox user.js ────────────────────────────────────────────────

ARKENFOX_URL = https://github.com/arkenfox/user.js/releases/latest/download/user.js
FIREFOX_DIR  = $(HOME)/.config/mozilla/firefox

arkenfox:
	@echo "==> downloading arkenfox user.js"
	@curl -sL "$(ARKENFOX_URL)" -o /tmp/user.js || \
	  { echo "failed to download user.js"; exit 1; }
	@profiles=$$(find "$(FIREFOX_DIR)" -maxdepth 1 -type d -name '*.default*' 2>/dev/null); \
	if [ -z "$$profiles" ]; then \
	  echo "    no Firefox profiles found in $(FIREFOX_DIR)"; \
	  echo "    start Firefox once to create a profile, then re-run 'make arkenfox'"; \
	  rm -f /tmp/user.js; \
	  exit 0; \
	fi; \
	for d in $$profiles; do \
	  cp /tmp/user.js "$$d/user.js"; \
	  echo "    $$d/user.js"; \
	done; \
	rm -f /tmp/user.js
	@echo "    restart Firefox to apply"

# ── opencode ─────────────────────────────────────────────────────────

OPENCODE_URL = https://opencode.ai/install

opencode:
	@echo "==> installing opencode"
	@curl -fsSL "$(OPENCODE_URL)" | bash

# ── doas (needs root) ───────────────────────────────────────────────

doas-install:
	@test -f doas/doas.conf || { echo "doas/doas.conf not found"; exit 1; }
	@echo "==> $(ETCDIR)/doas.conf"
	@if [ -e "$(ETCDIR)/doas.conf" ]; then \
	  $(DOAS) install -o root -g root -m 0644 \
	    "$$(pwd)/doas/doas.conf" "$(ETCDIR)/doas.conf"; \
	else \
	  echo "    bootstrapping (no doas yet, using su)"; \
	  su -c "install -o root -g root -m 0644 \
	    '$$(pwd)/doas/doas.conf' '$(ETCDIR)/doas.conf'"; \
	fi

doas-uninstall:
	@if [ -e "$(ETCDIR)/doas.conf" ] && cmp -s "$(ETCDIR)/doas.conf" doas/doas.conf; then \
	  $(DOAS) rm -v "$(ETCDIR)/doas.conf"; \
	else \
	  echo "$(ETCDIR)/doas.conf differs or doesn't exist; run 'make doas-diff'"; \
	fi

doas-diff:
	@$(DOAS) diff -u "$(ETCDIR)/doas.conf" doas/doas.conf || true

# ── cleanup ──────────────────────────────────────────────────────────

clean:
	@find "$(PREFIX)" -maxdepth 4 -type l ! -exec test -e {} \; -print 2>/dev/null | \
	while read -r l; do \
	  case "$$l" in \
	    "$(PREFIX)/.config/opencode"*) ;; \
	    *) case "$$(readlink "$$l")" in \
	      "$$(pwd)"/*) echo "rm $$l"; rm "$$l" ;; \
	    esac ;; \
	  esac; \
	done
