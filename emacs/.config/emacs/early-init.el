;; early-init.el

(setq package-enable-at-startup nil)

(setq inhibit-x-resources t)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;; Evita redimensionamento implícito da janela
(setq frame-inhibit-implied-resize t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(tooltip-mode -1)

(blink-cursor-mode -1)

(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

(setq use-dialog-box nil)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq frame-title-format "%b")

(set-fringe-mode 0)

(setq ring-bell-function #'ignore)
