# dotfiles Makefile — thin wrapper around bin/dotfiles
#
# Core commands delegate to the POSIX sh script at bin/dotfiles.
# System-level targets (doas, local.d, deps, etc.) live here.

PREFIX  = $(HOME)
DOAS    = doas
ETCDIR  = /etc

BOLD  = \033[1m
DIM   = \033[2m
CYAN  = \033[36m
GREEN = \033[32m
RED   = \033[31m
YELLOW = \033[33m
NC    = \033[0m

PKGS = foot havoc kak profile qutebrowser tmux vis river mako gtk jj shell git swayidle

# Packages installed by `make deps` — edit for your distro
DEPS = \
  foot mksh tmux \
  kakoune vis \
  qutebrowser firefox ublock-origin \
  river zig wayland-dev sandbar wlr-randr grim slurp wl-clipboard wbg waylock wlopm \
  mako \
  swayidle \
  jujutsu git \
  wireplumber playerctl brightnessctl \
  doas seatd dbus zzz less curl make

# Standard services to enable — edit for your init system
# NOTE: elogind provides seat management; do NOT enable seatd
# alongside elogind — they conflict on seat/session control.
SERVICES = \
  elogind \
  dbus 

.PHONY: all install uninstall relink status list help \
        clean arkenfox opencode \
        system-install system-uninstall \
        doas doas-install doas-uninstall doas-diff \
        local.d-install local.d-uninstall local.d-diff \
        services services-list \
        zrwm-build \
        deps bootstrap update \
        $(PKGS)

all: help

# ── core (delegated to bin/dotfiles) ──────────────────────────────────

install uninstall relink status list clean:
	@bin/dotfiles $@

$(PKGS):
	@bin/dotfiles $@

# ── help ──────────────────────────────────────────────────────────────

help:
	@PM=$$(command -v apk >/dev/null 2>&1 && echo 'apk'     && exit 0; \
	      command -v apt-get >/dev/null 2>&1 && echo 'apt'     && exit 0; \
	      command -v pacman >/dev/null 2>&1 && echo 'pacman'  && exit 0; \
	      command -v dnf >/dev/null 2>&1 && echo 'dnf'     && exit 0; \
	      command -v zypper >/dev/null 2>&1 && echo 'zypper'  && exit 0; \
	      command -v xbps-install >/dev/null 2>&1 && echo 'xbps'  && exit 0; \
	      command -v emerge >/dev/null 2>&1 && echo 'emerge'  && exit 0; \
	      command -v brew >/dev/null 2>&1 && echo 'brew'    && exit 0; \
	      command -v nix >/dev/null 2>&1 && echo 'nix'     && exit 0; \
	      command -v guix >/dev/null 2>&1 && echo 'guix'    && exit 0; \
	      command -v pkg >/dev/null 2>&1 && echo 'pkg'     && exit 0; \
	      command -v pkg_add >/dev/null 2>&1 && echo 'pkg_add' && exit 0; \
	      echo 'unknown'); \
	COUNT=$$(echo $(PKGS) | wc -w | tr -d ' '); \
	printf "$(BOLD)  ── dotfiles ────────────────────────────────────$(NC)\n"; \
	printf "  $(DIM)$$COUNT packages  ·  $$PM  ·  $(PREFIX)$(NC)\n"; \
	printf "\n"; \
	printf "$(BOLD)  📦 Packages$(NC)\n"; \
	printf "    $(GREEN)make install$(NC)       Symlink all packages into $(DIM)$(PREFIX)$(NC)\n"; \
	printf "    $(GREEN)make uninstall$(NC)     Remove our symlinks\n"; \
	printf "    $(GREEN)make relink$(NC)        Uninstall + install\n"; \
	printf "    $(GREEN)make status$(NC)        Show link state $(DIM)(✓ / ✗ / ⚠)$(NC)\n"; \
	printf "    $(GREEN)make list$(NC)          List available packages\n"; \
	printf "    $(GREEN)make <pkg>$(NC)         Install one package $(DIM)(e.g. make foot)$(NC)\n"; \
	printf "    $(GREEN)make clean$(NC)         Remove broken symlinks from $(DIM)$(PREFIX)$(NC)\n"; \
	printf "\n"; \
	printf "$(BOLD)  🌐 System Packages$(NC)\n"; \
	printf "    $(GREEN)make deps$(NC)          Install required packages $(DIM)(auto-detected: $$PM)$(NC)\n"; \
	printf "    $(GREEN)make services$(NC)      Enable standard services $(DIM)(elogind, seatd, dbus, ...)$(NC)\n"; \
	printf "    $(GREEN)make bootstrap$(NC)     deps + install $(DIM)(full setup)$(NC)\n"; \
	printf "    $(GREEN)make update$(NC)        git pull --ff-only + relink\n"; \
	printf "\n"; \
	printf "$(BOLD)  🛡️  Administration$(NC)\n"; \
	printf "    $(GREEN)make system-install$(NC)   install /etc/doas.conf + /etc/local.d/*\n"; \
	printf "    $(GREEN)make system-uninstall$(NC) remove all system files\n"; \
	printf "    $(GREEN)make doas-install$(NC)     install /etc/doas.conf\n"; \
	printf "    $(GREEN)make doas-uninstall$(NC)   remove /etc/doas.conf\n"; \
	printf "    $(GREEN)make doas-diff$(NC)        diff /etc/doas.conf with repo\n"; \
	printf "    $(GREEN)make local.d-install$(NC)  install /etc/local.d/*\n"; \
	printf "    $(GREEN)make local.d-uninstall$(NC) remove /etc/local.d/*\n"; \
	printf "    $(GREEN)make local.d-diff$(NC)     diff /etc/local.d/ with repo\n"; \
	printf "\n"; \
	printf "$(BOLD)  🔧 Extras$(NC)\n"; \
	printf "    $(GREEN)make arkenfox$(NC)      deploy arkenfox user.js to Firefox profiles\n"; \
	printf "    $(GREEN)make opencode$(NC)      install opencode\n"; \
	printf "    $(GREEN)make zrwm-build$(NC)   build & install zrwm from source\n"

# ── arkenfox user.js ────────────────────────────────────────────────

ARKENFOX_URL = https://github.com/arkenfox/user.js/releases/latest/download/user.js
FIREFOX_DIR  = $(HOME)/.config/mozilla/firefox

arkenfox:
	@printf "  $(BOLD)$(CYAN)─── arkenfox user.js ───$(NC)\n"
	@printf "  $(DIM)↓ downloading...$(NC)\n"
	@curl -sL "$(ARKENFOX_URL)" -o /tmp/user.js || \
	  { printf "  $(RED)✗$(NC)  failed to download user.js\n"; exit 1; }
	@profiles=$$(find "$(FIREFOX_DIR)" -maxdepth 1 -type d -name '*.default*' 2>/dev/null); \
	if [ -z "$$profiles" ]; then \
	  printf "  $(YELLOW)⚠$(NC)  no Firefox profiles found in $(DIM)$(FIREFOX_DIR)$(NC)\n"; \
	  printf "    start Firefox once to create a profile, then re-run 'make arkenfox'\n"; \
	  rm -f /tmp/user.js; \
	  exit 0; \
	fi; \
	for d in $$profiles; do \
	  cp /tmp/user.js "$$d/user.js"; \
	  printf "  $(GREEN)✓$(NC)  $(DIM)$$d/user.js$(NC)\n"; \
	done; \
	rm -f /tmp/user.js
	@printf "  $(GREEN)✓$(NC)  done — restart Firefox to apply\n"

# ── opencode ─────────────────────────────────────────────────────────

OPENCODE_URL = https://opencode.ai/install

opencode:
	@printf "  $(BOLD)$(CYAN)─── opencode ───$(NC)\n"
	@curl -fsSL "$(OPENCODE_URL)" | bash

# ── zrwm (build from source) ───────────────────────────────────────────

ZRWM_REPO = https://git.sr.ht/~zuki/zrwm
ZRWM_DIR  = /tmp/zrwm-build
ZRWM_BIN  = /usr/local/bin

zrwm-build:
	@trap '' 21 22; \
	printf "  $(BOLD)$(CYAN)─── zrwm ───$(NC)\n"; \
	rm -rf "$(ZRWM_DIR)"; \
	if ! git clone --depth 1 "$(ZRWM_REPO)" "$(ZRWM_DIR)" 2>/dev/null; then \
	  printf "  $(RED)✗$(NC)  failed to clone zrwm\n"; exit 1; \
	fi; \
	printf "  $(DIM)building...$(NC)\n"; \
	if ! $(MAKE) -C "$(ZRWM_DIR)" >/dev/null 2>&1; then \
	  printf "  $(RED)✗$(NC)  build failed — check dependencies (zig, wayland-dev)\n"; exit 1; \
	fi; \
	if [ "$$(id -u)" != "0" ]; then \
	  printf "  $(YELLOW)⚠$(NC)  run as root:\n"; \
	  printf "    $(BOLD)doas make zrwm-build$(NC)\n"; \
	  exit 1; \
	fi; \
	install -m 0755 "$(ZRWM_DIR)/zrwm" "$(ZRWM_DIR)/zrwm-msg" "$(ZRWM_BIN)/" && \
	printf "  $(GREEN)✓$(NC)  zrwm installed\n"

# ── system (needs root) ─────────────────────────────────────────────
# doas/doas.conf  →  /etc/doas.conf        (root-owned copy)
# local.d/*       →  /etc/local.d/          (root-owned copy)

DOAS_SRC  = $$(pwd)/doas/doas.conf
DOAS_DST  = $(ETCDIR)/doas.conf
LOCAL_SRC = $$(pwd)/local.d
LOCAL_DST = $(ETCDIR)/local.d

system-install: doas-install local.d-install
system-uninstall: doas-uninstall local.d-uninstall

doas: doas-install

doas-install:
	@test -f $(DOAS_SRC) || { printf "  $(RED)✗$(NC)  $(DOAS_SRC) not found\n"; exit 1; }
	@printf "  $(BOLD)$(CYAN)─── $(DOAS_DST) ───$(NC)\n"
	@if command -v doas >/dev/null 2>&1 && [ -e "$(DOAS_DST)" ]; then \
	  doas install -o root -g root -m 0644 "$(DOAS_SRC)" "$(DOAS_DST)" && \
	  printf "  $(GREEN)✓$(NC)  installed\n"; \
	else \
	  printf "  $(YELLOW)⚠$(NC)  bootstrapping $(DIM)(no doas yet, using su)$(NC)\n"; \
	  su -c "install -o root -g root -m 0644 '$(DOAS_SRC)' '$(DOAS_DST)'" && \
	  printf "  $(GREEN)✓$(NC)  installed\n"; \
	fi

doas-uninstall:
	@printf "  $(BOLD)$(CYAN)─── $(DOAS_DST) ───$(NC)\n"
	@if [ -e "$(DOAS_DST)" ] && cmp -s "$(DOAS_DST)" "$(DOAS_SRC)"; then \
	  doas rm "$(DOAS_DST)" && \
	  printf "  $(RED)✗$(NC)  $(DIM)$(DOAS_DST) removed$(NC)\n"; \
	else \
	  printf "  $(YELLOW)⚠$(NC)  $(DIM)$(DOAS_DST)$(NC) differs or does not exist; run 'make doas-diff'\n"; \
	fi

doas-diff:
	@printf "  $(BOLD)$(CYAN)─── diff $(DOAS_DST) ───$(NC)\n"
	@doas diff -u "$(DOAS_DST)" "$(DOAS_SRC)" || true

local.d-install:
	@test -d $(LOCAL_SRC) || { printf "  $(RED)✗$(NC)  $(LOCAL_SRC) not found\n"; exit 1; }
	@printf "  $(BOLD)$(CYAN)─── $(LOCAL_DST) ───$(NC)\n"
	@if command -v doas >/dev/null 2>&1 && doas -C /etc/doas.conf true 2>/dev/null; then \
	  doas mkdir -p "$(LOCAL_DST)" && \
	  doas install -o root -g root -m 0755 "$(LOCAL_SRC)/"* "$(LOCAL_DST)/" && \
	  printf "  $(GREEN)✓$(NC)  installed\n"; \
	else \
	  printf "  $(YELLOW)⚠$(NC)  bootstrapping $(DIM)(no doas yet, using su)$(NC)\n"; \
	  su -c "mkdir -p '$(LOCAL_DST)' && install -o root -g root -m 0755 '$(LOCAL_SRC)/'* '$(LOCAL_DST)/'" && \
	  printf "  $(GREEN)✓$(NC)  installed\n"; \
	fi

local.d-uninstall:
	@printf "  $(BOLD)$(CYAN)─── $(LOCAL_DST) ───$(NC)\n"
	@for f in "$(LOCAL_SRC)"/*; do \
	  name=$${f##*/}; \
	  dest="$(LOCAL_DST)/$$name"; \
	  if [ -f "$$dest" ] && cmp -s "$$dest" "$$f"; then \
	    doas rm "$$dest" && printf "  $(RED)✗$(NC)  $(DIM)$$dest removed$(NC)\n"; \
	  else \
	    printf "  $(YELLOW)⚠$(NC)  $(DIM)$$dest$(NC) differs or does not exist\n"; \
	  fi; \
	done

local.d-diff:
	@printf "  $(BOLD)$(CYAN)─── diff $(LOCAL_DST) ───$(NC)\n"
	@for f in "$(LOCAL_SRC)"/*; do \
	  name=$${f##*/}; \
	  dest="$(LOCAL_DST)/$$name"; \
	  printf "  $(BOLD)$(CYAN)--- $$name$(NC)\n"; \
	  diff -u "$$dest" "$$f" 2>/dev/null || true; \
	done

# ── services ──────────────────────────────────────────────────────
# Enable standard system services (elogind, seatd, dbus, …).
# Detects init system: OpenRC, systemd, runit, s6.

services:
	@trap '' 21 22; \
	INIT=""; ENABLE=""; \
	if command -v rc-update >/dev/null 2>&1; then \
	  INIT="openrc"; ENABLE="rc-update add"; \
	elif command -v systemctl >/dev/null 2>&1; then \
	  INIT="systemd"; ENABLE="systemctl enable"; \
	elif command -v sv >/dev/null 2>&1; then \
	  INIT="runit"; ENABLE="ln -s /etc/sv"; \
	elif command -v s6-svc >/dev/null 2>&1; then \
	  INIT="s6"; ENABLE="s6-service enable"; \
	else \
	  printf "  $(YELLOW)⚠$(NC)  unknown init system; enable services manually\n"; exit 1; \
	fi; \
	if [ -z "$(SERVICES)" ]; then \
	  printf "  $(YELLOW)⚠$(NC)  no services configured — edit SERVICES in Makefile\n"; exit 1; \
	fi; \
	printf "  $(BOLD)$(CYAN)─── enabling services ($$INIT) ───$(NC)\n"; \
	for svc in $(SERVICES); do \
	  if $$ENABLE $$svc 2>/dev/null; then \
	    printf "  $(GREEN)✓$(NC)  $$svc enabled\n"; \
	  else \
	    printf "  $(YELLOW)⚠$(NC)  could not enable $$svc $(DIM)(not installed?)$(NC)\n"; \
	  fi; \
	done

services-list:
	@printf "  $(BOLD)$(CYAN)─── configured SERVICES ───$(NC)\n"; \
	for svc in $(SERVICES); do printf "    • $$svc\n"; done

# ── distro-agnostic installer ──────────────────────────────────────
#
# PM detection, escalation, and package lists are all computed inside
# the recipe to avoid bmake-incompatible $(shell ...) and signal-prone !=.
#
# To add a package manager, add a case entry below with CMD, DEPS, and NEEDS_ROOT.

deps:
	@trap '' 21 22; \
	PM=""; CMD=""; NEEDS_ROOT=""; \
	\
	if command -v apk >/dev/null 2>&1; then \
	  PM="apk"; CMD="apk add"; NEEDS_ROOT=1; \
	elif command -v apt-get >/dev/null 2>&1; then \
	  PM="apt"; CMD="apt-get install -y"; NEEDS_ROOT=1; \
	elif command -v pacman >/dev/null 2>&1; then \
	  PM="pacman"; CMD="pacman -S --noconfirm"; NEEDS_ROOT=1; \
	elif command -v dnf >/dev/null 2>&1; then \
	  PM="dnf"; CMD="dnf install -y"; NEEDS_ROOT=1; \
	elif command -v zypper >/dev/null 2>&1; then \
	  PM="zypper"; CMD="zypper install -y"; NEEDS_ROOT=1; \
	elif command -v xbps-install >/dev/null 2>&1; then \
	  PM="xbps"; CMD="xbps-install -S"; NEEDS_ROOT=1; \
	elif command -v emerge >/dev/null 2>&1; then \
	  PM="emerge"; CMD="emerge"; NEEDS_ROOT=1; \
	elif command -v brew >/dev/null 2>&1; then \
	  PM="brew"; CMD="brew install"; NEEDS_ROOT=0; \
	elif command -v nix >/dev/null 2>&1; then \
	  PM="nix"; CMD="nix profile install"; NEEDS_ROOT=0; \
	elif command -v guix >/dev/null 2>&1; then \
	  PM="guix"; CMD="guix install"; NEEDS_ROOT=0; \
	elif command -v pkg >/dev/null 2>&1; then \
	  PM="pkg"; CMD="pkg install -y"; NEEDS_ROOT=1; \
	elif command -v pkg_add >/dev/null 2>&1; then \
	  PM="pkg_add"; CMD="pkg_add"; NEEDS_ROOT=1; \
	else \
	  printf "  $(YELLOW)⚠$(NC)  unknown distro; install packages manually\n"; exit 1; \
	fi; \
	\
	if [ -z "$(DEPS)" ]; then \
	  printf "  $(YELLOW)⚠$(NC)  no packages configured — edit DEPS in Makefile\n"; exit 1; \
	fi; \
	\
	printf "  $(BOLD)$(CYAN)─── installing packages ($$PM) ───$(NC)\n"; \
	if [ "$$NEEDS_ROOT" = "1" ]; then \
	  if [ "$$(id -u)" != "0" ]; then \
	    printf "  $(YELLOW)⚠$(NC)  run as root:\n"; \
	    printf "    $(BOLD)doas make deps$(NC)\n"; \
	    exit 1; \
	  fi; \
	fi; \
	if $$CMD $(DEPS); then \
	  printf "  $(GREEN)✓$(NC)  done\n"; \
	else \
	  printf "  $(RED)✗$(NC)  command failed\n"; exit 1; \
	fi

bootstrap:
	@$(MAKE) deps
	@$(MAKE) install
	@$(MAKE) services
	@printf "  $(GREEN)✓$(NC)  bootstrap complete\n"

update:
	@printf "  $(BOLD)$(CYAN)─── pulling latest ───$(NC)\n"
	@git pull --ff-only
	@printf "  $(GREEN)✓$(NC)  up to date\n"
	@$(MAKE) relink
	@printf "  $(GREEN)✓$(NC)  update complete\n"
