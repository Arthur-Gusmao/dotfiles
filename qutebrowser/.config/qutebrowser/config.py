# qutebrowser config — gruvbox, privacy, vis editor
import os

config.load_autoconfig(False)

# ─── editor ──────────────────────────────────────────────────────────
c.editor.command = [
    os.environ.get("TERMINAL", "foot"),
    "-e",
    os.environ.get("EDITOR", "vis"),
    "{file}",
]

# ─── per-site exceptions ──────────────────────────────────────────────
# devtools need cookies/js/images
for pattern in ("chrome-devtools://*", "devtools://*"):
    config.set("content.cookies.accept", "all", pattern)
    config.set("content.images", True, pattern)
    config.set("content.javascript.enabled", True, pattern)
config.set("content.javascript.enabled", True, "chrome://*/*")
config.set("content.javascript.enabled", True, "qute://*/*")

# google login requires firefox user-agent
config.set(
    "content.headers.user_agent",
    "Mozilla/5.0 ({os_info}; rv:149.0) Gecko/20100101 Firefox/149.0",
    "https://accounts.google.com/*",
)
config.set(
    "content.headers.user_agent",
    "Mozilla/5.0 ({os_info}) AppleWebKit/{webkit_version} (KHTML, like Gecko) "
    "{qt_key}/{qt_version} {upstream_browser_key}/{upstream_browser_version_short} "
    "Safari/{webkit_version}",
    "https://gitlab.gnome.org/*",
)
config.set("content.headers.accept_language", "", "https://matchmaker.krunker.io/*")

config.set("content.javascript.clipboard", "access-paste", "https://gemini.google.com")
config.set("content.notifications.enabled", True, "https://www.youtube.com")
config.set(
    "content.local_content_can_access_remote_urls", True,
    "file:///home/aw/.local/share/qutebrowser/userscripts/*",
)
config.set(
    "content.local_content_can_access_file_urls", False,
    "file:///home/aw/.local/share/qutebrowser/userscripts/*",
)

# ─── privacy ──────────────────────────────────────────────────────────
config.set("content.webgl", False, "*")
config.set("content.canvas_reading", False)
config.set("content.geolocation", False)
config.set("content.webrtc_ip_handling_policy", "default-public-interface-only")
config.set("content.cookies.store", True)

c.content.blocking.enabled = True
c.content.blocking.method = "adblock"
c.content.blocking.adblock.lists = [
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/legacy.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2020.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2021.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2022.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2023.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/filters-2024.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badware.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances-cookies.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances-others.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/badlists.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/quick-fixes.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/resource-abuse.txt",
    "https://github.com/uBlockOrigin/uAssets/raw/master/filters/unbreak.txt",
]

# ─── dark mode ───────────────────────────────────────────────────────
config.set("colors.webpage.darkmode.enabled", True)
config.set("colors.webpage.darkmode.enabled", False, "file://*")
c.colors.webpage.darkmode.algorithm = "lightness-cielab"
c.colors.webpage.darkmode.policy.images = "never"

# ─── gruvbox ─────────────────────────────────────────────────────────
c.colors.completion.fg = ["#ebdbb2", "#ebdbb2", "#ebdbb2"]
c.colors.completion.odd.bg = "#282828"
c.colors.completion.even.bg = "#3c3836"
c.colors.completion.category.fg = "#fabd2f"
c.colors.completion.category.bg = (
    "qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #282828, stop:1 #3c3836)"
)
c.colors.completion.category.border.top = "#504945"
c.colors.completion.category.border.bottom = "#504945"
c.colors.completion.item.selected.fg = "#282828"
c.colors.completion.item.selected.bg = "#fabd2f"
c.colors.completion.item.selected.match.fg = "#83a598"
c.colors.completion.match.fg = "#83a598"
c.colors.completion.scrollbar.fg = "#ebdbb2"
c.colors.downloads.bar.bg = "#282828"
c.colors.downloads.error.bg = "#fb4934"
c.colors.hints.fg = "#ebdbb2"
c.colors.hints.bg = "#282828"
c.colors.hints.match.fg = "#b8bb26"
c.colors.messages.info.bg = "#282828"
c.colors.statusbar.normal.bg = "#282828"
c.colors.statusbar.insert.fg = "#ebdbb2"
c.colors.statusbar.insert.bg = "#b8bb26"
c.colors.statusbar.passthrough.bg = "#83a598"
c.colors.statusbar.command.bg = "#282828"
c.colors.statusbar.url.warn.fg = "#fe8019"
c.colors.tabs.bar.bg = "#1d2021"
c.colors.tabs.odd.bg = "#282828"
c.colors.tabs.even.bg = "#282828"
c.colors.tabs.selected.odd.bg = "#3c3836"
c.colors.tabs.selected.even.bg = "#3c3836"
c.colors.tabs.pinned.odd.bg = "#b8bb26"
c.colors.tabs.pinned.even.bg = "#b8bb26"
c.colors.tabs.pinned.selected.odd.bg = "#3c3836"
c.colors.tabs.pinned.selected.even.bg = "#3c3836"

# ─── fonts ───────────────────────────────────────────────────────────
c.fonts.default_family = '"IosevkaTerm Nerd Font"'
c.fonts.default_size = "11pt"
c.fonts.completion.entry = '11pt "IosevkaTerm Nerd Font"'
c.fonts.debug_console = '11pt "IosevkaTerm Nerd Font"'
c.fonts.prompts = "default_size sans-serif"
c.fonts.statusbar = '11pt "IosevkaTerm Nerd Font"'
c.fonts.tabs.selected = '10pt "IosevkaTerm Nerd Font"'
c.fonts.tabs.unselected = '10pt "IosevkaTerm Nerd Font"'

# ─── readline insert mode ────────────────────────────────────────────
config.bind("<Ctrl-h>", "fake-key <Backspace>", "insert")
config.bind("<Ctrl-a>", "fake-key <Home>", "insert")
config.bind("<Ctrl-e>", "fake-key <End>", "insert")
config.bind("<Ctrl-b>", "fake-key <Left>", "insert")
config.bind("<Mod1-b>", "fake-key <Ctrl-Left>", "insert")
config.bind("<Ctrl-f>", "fake-key <Right>", "insert")
config.bind("<Mod1-f>", "fake-key <Ctrl-Right>", "insert")
config.bind("<Ctrl-p>", "fake-key <Up>", "insert")
config.bind("<Ctrl-n>", "fake-key <Down>", "insert")
config.bind("<Mod1-d>", "fake-key <Ctrl-Delete>", "insert")
config.bind("<Ctrl-d>", "fake-key <Delete>", "insert")
config.bind("<Ctrl-w>", "fake-key <Ctrl-Backspace>", "insert")
config.bind("<Ctrl-u>", "fake-key <Shift-Home><Delete>", "insert")
config.bind("<Ctrl-k>", "fake-key <Shift-End><Delete>", "insert")
config.bind("<Ctrl-x><Ctrl-e>", "open-editor", "insert")

# ─── toggles ─────────────────────────────────────────────────────────
config.bind("xb", "config-cycle statusbar.show always never")
config.bind("xt", "config-cycle tabs.show always never")
config.bind("xx", "config-cycle statusbar.show always never;; config-cycle tabs.show always never")
