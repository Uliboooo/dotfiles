;;; init.el --- Seli Emacs config -*- lexical-binding: t; -*-

;;; Commentary:
;; Org mode 専用の構成。プログラミング向けの機能 (LSP, 診断, フォーマッタ,
;; デバッガ, 各言語 major mode, Git クライアント, 端末) は持たない。

;;; Package bootstrap

(require 'package)

;; Keep third-party byte/native compilation noise out of the startup UI.
(setq native-comp-async-report-warnings-errors 'silent
      byte-compile-warnings '(not obsolete free-vars unresolved noruntime lexical make-local)
      warning-suppress-types '((bytecomp) (comp) (native-compiler))
      warning-suppress-log-types '((bytecomp) (comp) (native-compiler)))

(add-to-list 'display-buffer-alist
             '("\\`\\*Warnings\\*\\'" . (display-buffer-no-window)))
(add-to-list 'display-buffer-alist
             '("\\`\\*Compile-Log\\*\\'" . (display-buffer-no-window)))

(defconst seli/opaque-ui-background "#2a273f")
(defconst seli/opaque-ui-background-active "#393552")
(defconst seli/buffer-alpha-background 88)

(defconst seli/cache-dir
  (expand-file-name "emacs/" (or (getenv "XDG_CACHE_HOME") "~/.cache/")))

(defconst seli/state-dir
  (expand-file-name "emacs/" (or (getenv "XDG_STATE_HOME") "~/.local/state/")))

(defconst seli/data-dir
  (expand-file-name "emacs/" (or (getenv "XDG_DATA_HOME") "~/.local/share/")))

(defconst seli/config-dir
  (file-name-directory (or load-file-name buffer-file-name)))

(dolist (dir (list seli/cache-dir seli/state-dir seli/data-dir))
  (unless (file-directory-p dir)
    (make-directory dir t)))

(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))

(setq package-user-dir (expand-file-name "elpa" seli/data-dir))
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-always-defer t
      use-package-expand-minimally t)

;;; Evil must see these before any Evil-related package is loaded.

(setq evil-want-keybinding nil
      evil-want-C-u-scroll t
      evil-want-C-i-jump nil
      evil-respect-visual-line-mode t
      evil-default-cursor 'box
      evil-normal-state-cursor 'box
      evil-emacs-state-cursor 'box
      evil-visual-state-cursor 'box
      evil-insert-state-cursor 'bar
      evil-replace-state-cursor 'bar
      evil-operator-state-cursor 'hbar
      evil-motion-state-cursor 'box)

(defconst seli/terminal-cursor-shapes
  '((box . "\e[2 q")
    (bar . "\e[6 q")
    (hbar . "\e[4 q"))
  "DECSCUSR cursor shape escape sequences for terminal Emacs.")

(defun seli/set-cursor-shape (shape)
  "Set cursor SHAPE in GUI and terminal frames."
  (setq-default cursor-type shape)
  (setq cursor-type shape)
  (unless (display-graphic-p)
    (let ((sequence (alist-get shape seli/terminal-cursor-shapes)))
      (when sequence
        (send-string-to-terminal sequence)))))

(defun seli/apply-evil-cursor-shape ()
  "Apply cursor shape for the current Evil state."
  (seli/set-cursor-shape
   (pcase (and (boundp 'evil-state) evil-state)
     ('insert 'bar)
     ('replace 'bar)
     ('operator 'hbar)
     ('normal 'box)
     ('visual 'box)
     ('motion 'box)
     ('emacs 'box)
     (_ 'box))))

;;; Files, backups, and XDG-friendly state

(setq backup-directory-alist `(("." . ,(expand-file-name "backup/" seli/cache-dir)))
      auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-save/" seli/cache-dir) t))
      auto-save-list-file-prefix (expand-file-name "auto-save-list/.saves-" seli/cache-dir)
      create-lockfiles nil
      custom-file (expand-file-name "custom.el" seli/state-dir)
      recentf-save-file (expand-file-name "recentf" seli/state-dir)
      savehist-file (expand-file-name "savehist" seli/state-dir)
      bookmark-default-file (expand-file-name "bookmarks" seli/state-dir))

(dolist (dir (list (expand-file-name "backup/" seli/cache-dir)
                  (expand-file-name "auto-save/" seli/cache-dir)
                  (expand-file-name "auto-save-list/" seli/cache-dir)))
  (unless (file-directory-p dir)
    (make-directory dir t)))

;;; Core editor behavior

(setq inhibit-startup-screen t
      ring-bell-function #'ignore
      visible-bell nil
      use-short-answers t
      confirm-kill-processes nil
      sentence-end-double-space nil
      require-final-newline t
      scroll-margin 3
      scroll-conservatively 101
      scroll-preserve-screen-position t
      scroll-step 1
      auto-window-vscroll nil
      fast-but-imprecise-scrolling t
      next-screen-context-lines 3
      tab-width 2
      standard-indent 2
      fill-column 100
      indent-tabs-mode nil)

(setq-default tab-width 2
              indent-tabs-mode nil
              truncate-lines nil)

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)

(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(global-hl-line-mode 1)
(column-number-mode 1)
(show-paren-mode 1)
(global-auto-revert-mode 1)
(delete-selection-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(winner-mode 1)

(setq auto-revert-verbose nil
      global-auto-revert-non-file-buffers t)

(setq-default show-trailing-whitespace nil)

(defun seli/save-all-buffers ()
  "Save modified file buffers without prompting."
  (save-some-buffers t))

(add-hook 'focus-out-hook #'seli/save-all-buffers)

(defface seli-dangerous-char
  '((t (:background "red" :foreground "white" :weight bold)))
  "Face for invisible or bidi control characters.")

(font-lock-add-keywords
 nil
 '(("[\u200B\u200C\u200D\uFEFF\u202E\u2066-\u2069]" 0 'seli-dangerous-char prepend)))

;;; UI

(defconst seli/transparent-background-faces
  '(default
    fringe
    line-number
    line-number-current-line
    vertical-border
    internal-border
    hl-line
    fill-column-indicator
    display-fill-column-indicator)
  "Buffer faces that should inherit the transparent frame background.")

(defconst seli/opaque-ui-faces
  '((menu . seli/opaque-ui-background-active)
    (tool-bar . seli/opaque-ui-background-active)
    (tab-bar . seli/opaque-ui-background-active)
    (tab-bar-tab . seli/opaque-ui-background)
    (tab-bar-tab-inactive . seli/opaque-ui-background-active)
    (tab-bar-tab-group-current . seli/opaque-ui-background)
    (tab-bar-tab-group-inactive . seli/opaque-ui-background-active)
    (tab-bar-tab-ungrouped . seli/opaque-ui-background-active)
    (tab-line . seli/opaque-ui-background)
    (tab-line-tab . seli/opaque-ui-background-active)
    (tab-line-tab-current . seli/opaque-ui-background-active)
    (tab-line-tab-inactive . seli/opaque-ui-background)
    (tab-line-highlight . seli/opaque-ui-background-active)
    (tab-line-close-highlight . seli/opaque-ui-background-active)
    (header-line . seli/opaque-ui-background)
    (header-line-highlight . seli/opaque-ui-background-active)
    (mode-line . seli/opaque-ui-background-active)
    (mode-line-active . seli/opaque-ui-background-active)
    (mode-line-inactive . seli/opaque-ui-background)
    (mode-line-highlight . seli/opaque-ui-background-active))
  "UI faces that should stay opaque in GUI frames.")

(defun seli/apply-frame-appearance (&optional frame)
  "Apply frame appearance settings to FRAME."
  (let ((frame (or frame (selected-frame))))
    (dolist (face seli/transparent-background-faces)
      (when (facep face)
        (set-face-attribute face frame :background 'unspecified)
        (set-face-attribute face t :background 'unspecified)))
    (if (display-graphic-p frame)
        (progn
          (set-frame-parameter frame 'alpha '(100 . 100))
          (set-frame-parameter frame 'alpha-background seli/buffer-alpha-background)
          (dolist (entry seli/opaque-ui-faces)
            (let ((face (car entry))
                  (background (symbol-value (cdr entry))))
              (when (facep face)
                (set-face-attribute face frame :background background)
                (set-face-attribute face t :background background)))))
      (modify-frame-parameters frame '((background-color . "unspecified-bg"))))))

(defun seli/reapply-frame-appearance (&rest _)
  "Reapply frame appearance after theme changes."
  (dolist (frame (frame-list))
    (seli/apply-frame-appearance frame)))

(add-to-list 'default-frame-alist '(alpha . (100 . 100)))
(add-to-list 'default-frame-alist `(alpha-background . ,seli/buffer-alpha-background))
(add-hook 'after-make-frame-functions #'seli/apply-frame-appearance)
(advice-add 'load-theme :after #'seli/reapply-frame-appearance)
(seli/apply-frame-appearance)

(defconst seli/default-font-family "Monaspace Radon Var")
(defconst seli/default-font-height 130)
(defconst seli/cjk-font-family "Yomogi")

(defun seli/apply-fonts ()
  "Set the default monospace font and the CJK fallback font, if installed."
  (when (display-graphic-p)
    (when (member seli/default-font-family (font-family-list))
      (set-face-attribute 'default nil :family seli/default-font-family :height seli/default-font-height))
    (when (member seli/cjk-font-family (font-family-list))
      (dolist (charset '(kana han cjk-misc))
        (set-fontset-font t charset (font-spec :family seli/cjk-font-family))))))

(seli/apply-fonts)

(setq tab-bar-show nil
      tab-line-close-button-show nil
      tab-line-new-button-show nil
      tab-line-separator "")

(tab-bar-mode -1)
(global-tab-line-mode 1)

(add-to-list 'custom-theme-load-path (expand-file-name "themes/" seli/config-dir))
(load-theme 'rose-pine-moon t)

(defun seli/toggle-theme ()
  "Reload the configured theme."
  (interactive)
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'rose-pine-moon t))

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 22)
  (doom-modeline-buffer-file-name-style 'auto)
  (doom-modeline-icon t))

(use-package which-key
  :ensure nil
  :hook (after-init . which-key-mode)
  :custom
  (which-key-idle-delay 0.4))

;;; Evil and leader keys

(use-package evil-numbers
  :after evil
  :demand t)

(use-package evil
  :demand t
  :config
  (evil-mode 1)
  (dolist (hook '(evil-normal-state-entry-hook
                  evil-insert-state-entry-hook
                  evil-visual-state-entry-hook
                  evil-replace-state-entry-hook
                  evil-operator-state-entry-hook
                  evil-motion-state-entry-hook
                  evil-emacs-state-entry-hook))
    (add-hook hook #'seli/apply-evil-cursor-shape))
  (seli/apply-evil-cursor-shape)
  (define-key evil-normal-state-map (kbd "U") #'evil-redo)
  (define-key evil-normal-state-map (kbd "C-b") nil)
  (define-key evil-normal-state-map (kbd "C-a") #'evil-numbers/inc-at-pt)
  (define-key evil-normal-state-map (kbd "C-x") #'evil-numbers/dec-at-pt))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package general
  :demand t
  :after evil
  :config
  (general-create-definer seli/leader
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC"
    :non-normal-prefix "C-SPC")

  (seli/leader
    "SPC" '(execute-extended-command :which-key "M-x")
    "n" '(consult-focus-lines :which-key "hide non-matches")
    "f" '(seli/consult-fd-buffer-tab :which-key "find files")
    "/" '(consult-ripgrep :which-key "grep")
    "m" '(consult-mark :which-key "marks")
    "u" '(undo-redo :which-key "undo redo")
    "s" '(consult-imenu :which-key "outline")
    "S" '(consult-org-heading :which-key "org headings")
    "tb" '(seli/toggle-theme :which-key "toggle theme")
    "o" '(:ignore t :which-key "org")
    "ot" '(org-todo :which-key "todo state")
    "oc" '(org-toggle-checkbox :which-key "toggle checkbox")
    "ol" '(org-insert-link :which-key "insert link")
    "oo" '(org-open-at-point :which-key "open link")
    "oi" '(org-toggle-inline-images :which-key "toggle images")))

(global-set-key (kbd "C-s") #'save-buffer)

;;; Completion, search, and navigation

(use-package vertico
  :hook (after-init . vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :hook (after-init . marginalia-mode))

(use-package consult
  :bind (("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop))
  :custom
  (consult-fd-args "fd --color=never --hidden --exclude .git")
  (consult-ripgrep-args "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --hidden --glob !.git"))

(defun seli/consult-fd-buffer-tab ()
  "Find files with `consult-fd', showing opened buffers in `tab-line-mode'."
  (interactive)
  (call-interactively #'consult-fd))

(use-package corfu
  :hook (after-init . global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-quit-no-match 'separator)
  :bind (:map corfu-map
              ("RET" . corfu-insert)
              ("<return>" . corfu-insert)))

(use-package cape
  :after corfu
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;;; Org mode

(defun seli/org-mode-defaults ()
  "Prose-friendly defaults for `org-mode' buffers."
  (display-line-numbers-mode 0)
  (setq-local truncate-lines nil))

(use-package org
  :ensure nil
  :mode ("\\.org\\'" . org-mode)
  :hook ((org-mode . visual-line-mode)
         (org-mode . seli/org-mode-defaults))
  :custom
  (org-directory "~/org")
  (org-startup-indented t)
  (org-startup-folded 'content)
  (org-startup-with-inline-images t)
  (org-image-actual-width '(600))
  (org-pretty-entities t)
  (org-hide-emphasis-markers t)
  (org-ellipsis " ▾")
  (org-fontify-quote-and-verse-blocks t)
  (org-return-follows-link t)
  (org-insert-heading-respect-content t)
  (org-catch-invisible-edits 'show-and-error)
  (org-auto-align-tags nil)
  (org-tags-column 0))

;; `<q' TAB などのブロックテンプレート。
(use-package org-tempo
  :ensure nil
  :after org
  :demand t)

(use-package evil-org
  :after (evil org)
  :hook (org-mode . evil-org-mode)
  :config
  (evil-org-set-key-theme '(navigation insert textobjects additional calendar)))

(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :custom
  (org-modern-star 'replace)
  (org-modern-hide-stars nil)
  (org-modern-table t)
  (org-modern-list '((?+ . "◦") (?- . "–") (?* . "•"))))

;;; Files

(use-package dired
  :ensure nil
  :custom
  (dired-listing-switches "-alh --group-directories-first")
  :config
  (with-eval-after-load 'evil
    (evil-define-key 'normal dired-mode-map
      (kbd "RET") #'dired-find-file
      (kbd "<return>") #'dired-find-file
      (kbd "l") #'dired-find-file
      (kbd "h") #'dired-up-directory
      (kbd "^") #'dired-up-directory
      (kbd "q") #'quit-window)))

;;; Final local customizations

(when (file-exists-p custom-file)
  (load custom-file nil t))

;;; init.el ends here
