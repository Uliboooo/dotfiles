;;; init.el --- Seli Emacs config -*- lexical-binding: t; -*-

;;; Package bootstrap

(require 'package)
(require 'seq)

;; Keep third-party byte/native compilation noise out of the startup UI.
(setq native-comp-async-report-warnings-errors 'silent
      byte-compile-warnings '(not obsolete free-vars unresolved noruntime lexical make-local)
      warning-suppress-types '((bytecomp) (comp) (native-compiler))
      warning-suppress-log-types '((bytecomp) (comp) (native-compiler)))

(add-to-list 'display-buffer-alist
             '("\\`\\*Warnings\\*\\'" . (display-buffer-no-window)))
(add-to-list 'display-buffer-alist
             '("\\`\\*Compile-Log\\*\\'" . (display-buffer-no-window)))

(defconst seli/frame-alpha-background 88)

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

(setq treesit-extra-load-path (list (expand-file-name "tree-sitter/" seli/data-dir)))

(when (boundp 'treesit--install-language-grammar-out-dir)
  (setq treesit--install-language-grammar-out-dir
        (expand-file-name "tree-sitter/" seli/data-dir)))

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
      read-process-output-max (* 1024 1024)
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

(defun seli/prog-mode-defaults ()
  (setq-local indent-tabs-mode nil)
  (display-fill-column-indicator-mode 0))

(add-hook 'prog-mode-hook #'seli/prog-mode-defaults)

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
    mode-line
    mode-line-inactive
    mode-line-active
    header-line
    tab-bar
    tab-line
    hl-line
    fill-column-indicator
    display-fill-column-indicator)
  "Faces that should inherit the terminal background.")

(defun seli/apply-frame-appearance (&optional frame)
  "Apply frame appearance settings to FRAME."
  (let ((frame (or frame (selected-frame))))
    (dolist (face seli/transparent-background-faces)
      (when (facep face)
        (set-face-attribute face frame :background 'unspecified)
        (set-face-attribute face t :background 'unspecified)))
    (modify-frame-parameters frame '((background-color . "unspecified-bg")))
    (when (display-graphic-p frame)
      (set-frame-parameter frame 'alpha-background seli/frame-alpha-background))))

(defun seli/reapply-frame-appearance (&rest _)
  "Reapply frame appearance after theme changes."
  (dolist (frame (frame-list))
    (seli/apply-frame-appearance frame)))

(add-to-list 'default-frame-alist '(background-color . "unspecified-bg"))
(add-to-list 'default-frame-alist `(alpha-background . ,seli/frame-alpha-background))
(add-hook 'after-make-frame-functions #'seli/apply-frame-appearance)
(advice-add 'load-theme :after #'seli/reapply-frame-appearance)
(seli/apply-frame-appearance)

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
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-icon t))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package hl-todo
  :hook (prog-mode . hl-todo-mode))

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
  (define-key evil-normal-state-map (kbd "C-a") #'seli/increment-or-toggle-at-point)
  (define-key evil-normal-state-map (kbd "C-x") #'seli/decrement-or-toggle-at-point)
  (define-key evil-normal-state-map (kbd "K") #'eldoc-doc-buffer)
  (define-key evil-normal-state-map (kbd "gd") #'xref-find-definitions)
  (define-key evil-normal-state-map (kbd "gr") #'xref-find-references))

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
    "a" '(eglot-code-actions :which-key "code action")
    "r" '(eglot-rename :which-key "rename")
    "n" '(consult-focus-lines :which-key "hide non-matches")
    "f" '(consult-fd :which-key "find files")
    "/" '(consult-ripgrep :which-key "grep")
    "m" '(consult-mark :which-key "marks")
    "u" '(undo-redo :which-key "undo redo")
    "d" '(:ignore t :which-key "diagnostics/debug")
    "dd" '(consult-flymake :which-key "diagnostics")
    "dc" '(seli/copy-current-diagnostic :which-key "copy diagnostic")
    "s" '(consult-imenu :which-key "symbols")
    "S" '(consult-eglot-symbols :which-key "workspace symbols")
    "l" '(magit-status :which-key "magit")
    "\\" '(seli/toggle-terminal :which-key "terminal")
    "tb" '(seli/toggle-theme :which-key "toggle theme")
    "b" '(dape-breakpoint-toggle :which-key "toggle breakpoint")
    "dr" '(dape-repl :which-key "debug repl")))

(global-set-key (kbd "C-s") #'save-buffer)
(global-set-key (kbd "C-\\") #'seli/toggle-terminal)

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
  (consult-fd-args "fd --color=never --hidden --exclude .git --exclude node_modules --exclude target --exclude .mooncakes")
  (consult-ripgrep-args "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --hidden --glob !.git --glob !node_modules --glob !target --glob !.mooncakes"))

(use-package consult-eglot
  :after (consult eglot))

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

(use-package yasnippet
  :hook (after-init . yas-global-mode))

(use-package yasnippet-snippets
  :after yasnippet)

;;; Editing tools

(use-package smartparens
  :hook (prog-mode . smartparens-mode)
  :config
  (require 'smartparens-config))

(use-package apheleia
  :hook (after-init . apheleia-global-mode)
  :config
  (setf (alist-get 'stylua apheleia-formatters)
        '("stylua" "--column-width" "100" "--indent-type" "Spaces" "--indent-width" "2"
          "--quote-style" "AutoPreferDouble" "--collapse-simple-statement" "Always" "-"))
  (setf (alist-get 'shfmt apheleia-formatters) '("shfmt" "-i" "2"))
  (setf (alist-get 'rustic-mode apheleia-mode-alist) 'rustfmt)
  (setf (alist-get 'rust-mode apheleia-mode-alist) 'rustfmt)
  (setf (alist-get 'go-mode apheleia-mode-alist) 'gofmt)
  (setf (alist-get 'lua-mode apheleia-mode-alist) 'stylua)
  (setf (alist-get 'json-mode apheleia-mode-alist) 'biome)
  (setf (alist-get 'js-json-mode apheleia-mode-alist) 'biome)
  (setf (alist-get 'typescript-ts-mode apheleia-mode-alist) 'biome)
  (setf (alist-get 'tsx-ts-mode apheleia-mode-alist) 'biome)
  (setf (alist-get 'js-ts-mode apheleia-mode-alist) 'biome)
  (setf (alist-get 'nix-mode apheleia-mode-alist) 'nixfmt)
  (setf (alist-get 'toml-ts-mode apheleia-mode-alist) 'taplo)
  (setf (alist-get 'sh-mode apheleia-mode-alist) 'shfmt)
  (setf (alist-get 'c-mode apheleia-mode-alist) 'clang-format)
  (setf (alist-get 'c++-mode apheleia-mode-alist) 'clang-format))

(defun seli/toggle-comment ()
  "Toggle comment on current line or active region."
  (interactive)
  (if (use-region-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-line 1)))

(global-set-key (kbd "C-c") #'seli/toggle-comment)

(defun seli/boolean-at-point ()
  "Return bounds and replacement for boolean at point."
  (let* ((bounds (bounds-of-thing-at-point 'symbol))
         (word (and bounds (buffer-substring-no-properties (car bounds) (cdr bounds)))))
    (cond
     ((string= word "true") (list bounds "false"))
     ((string= word "false") (list bounds "true"))
     (t nil))))

(defun seli/toggle-boolean-at-point ()
  "Toggle true/false at point. Return non-nil when changed."
  (when-let* ((pair (seli/boolean-at-point))
              (bounds (car pair))
              (replacement (cadr pair)))
    (delete-region (car bounds) (cdr bounds))
    (insert replacement)
    t))

(defun seli/increment-or-toggle-at-point ()
  "Toggle boolean at point, otherwise increment number at point."
  (interactive)
  (unless (seli/toggle-boolean-at-point)
    (evil-numbers/inc-at-pt 1)))

(defun seli/decrement-or-toggle-at-point ()
  "Toggle boolean at point, otherwise decrement number at point."
  (interactive)
  (unless (seli/toggle-boolean-at-point)
    (evil-numbers/dec-at-pt 1)))

;;; LSP, diagnostics, and language modes

(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-no-changes-timeout 0.8)
  (flymake-show-diagnostics-at-end-of-line nil))

(use-package eglot
  :ensure nil
  :init
  (dolist (hook '(rust-mode-hook rust-ts-mode-hook
                  go-mode-hook go-ts-mode-hook
                  c-mode-hook c-ts-mode-hook c++-mode-hook c++-ts-mode-hook
                  python-mode-hook python-ts-mode-hook
                  js-mode-hook js-ts-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook
                  css-mode-hook css-ts-mode-hook html-mode-hook
                  lua-mode-hook
                  zig-mode-hook
                  markdown-mode-hook
                  nix-mode-hook
                  typst-ts-mode-hook
                  web-mode-hook))
    (add-hook hook #'eglot-ensure))
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  (eglot-ignored-server-capabilities '(:documentHighlightProvider))
  :config
  (add-to-list 'eglot-server-programs
               '((rust-mode rust-ts-mode)
                 . ("rust-analyzer" :initializationOptions
                    (:cargo (:allFeatures t)
                     :check (:command "clippy")
                     :inlayHints (:typeHints (:enable t)
                                  :parameterHints (:enable t)
                                  :chainingHints (:enable t)
                                  :lifetimeElisionHints (:enable t))))))
  (add-to-list 'eglot-server-programs
               '((js-mode js-ts-mode typescript-ts-mode tsx-ts-mode)
                 . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((c-mode c-ts-mode c++-mode c++-ts-mode) . ("clangd")))
  (add-to-list 'eglot-server-programs
               '((go-mode go-ts-mode) . ("gopls")))
  (add-to-list 'eglot-server-programs
               '(zig-mode . ("zls")))
  (add-to-list 'eglot-server-programs
               '(lua-mode . ("lua-language-server")))
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("basedpyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(nix-mode . ("nil")))
  (add-to-list 'eglot-server-programs
               '(typst-ts-mode . ("tinymist")))
  (add-to-list 'eglot-server-programs
               '(web-mode . ("astro-ls" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(markdown-mode . ("marksman")))
  (add-hook 'eglot-managed-mode-hook #'eglot-inlay-hints-mode))

(defun seli/copy-current-diagnostic ()
  "Copy first Flymake diagnostic on the current line with source context."
  (interactive)
  (let* ((line (line-number-at-pos))
         (line-start (line-beginning-position))
         (line-end (line-end-position))
         (diag (seq-find
                (lambda (d)
                  (and (<= (flymake-diagnostic-beg d) line-end)
                       (>= (flymake-diagnostic-end d) line-start)))
                (flymake-diagnostics line-start line-end))))
    (if (not diag)
        (message "No diagnostics found on current line.")
      (let* ((beg-line (max 1 (- line 3)))
             (end-line (+ line 3))
             (context (buffer-substring-no-properties
                       (save-excursion (goto-char (point-min)) (forward-line (1- beg-line)) (point))
                       (save-excursion (goto-char (point-min)) (forward-line end-line) (point))))
             (text (format "%s: %s at %d\n%s"
                           (flymake-diagnostic-type diag)
                           (flymake-diagnostic-text diag)
                           line
                           context)))
        (kill-new text)
        (message "Diagnostic copied to clipboard.")))))

(use-package markdown-mode)
(use-package nix-mode)
(use-package lua-mode)
(use-package go-mode)
(use-package rust-mode)
(use-package zig-mode)
(use-package json-mode)
(use-package toml-ts-mode
  :ensure nil
  :mode "\\.toml\\'")
(use-package typst-ts-mode
  :mode "\\.typ\\'")
(use-package web-mode
  :mode "\\.astro\\'")

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

(add-to-list 'auto-mode-alist '("\\.mbt\\'" . prog-mode))

;;; Git

(use-package magit
  :commands (magit-status magit-blame-addition))

(use-package diff-hl
  :hook ((prog-mode text-mode conf-mode) . diff-hl-mode)
  :config
  (diff-hl-flydiff-mode 1))

;;; Terminal and debug

(use-package eat
  :commands (eat eat-make)
  :config
  (define-key eat-mode-map (kbd "C-\\") #'seli/toggle-terminal)
  (when (boundp 'eat-semi-char-mode-map)
    (define-key eat-semi-char-mode-map (kbd "C-\\") #'seli/toggle-terminal))
  (when (boundp 'eat-char-mode-map)
    (define-key eat-char-mode-map (kbd "C-\\") #'seli/toggle-terminal)))

(defvar seli/terminal-buffer-name "*terminal*")
(defconst seli/terminal-window-height 0.3)

(defun seli/project-root-or-default-directory ()
  "Return project root when available, otherwise `default-directory'."
  (let ((project (project-current nil)))
    (if project (project-root project) default-directory)))

(defun seli/get-or-create-terminal-buffer ()
  "Return the dedicated terminal buffer, creating it when needed."
  (let* ((default-directory (seli/project-root-or-default-directory))
         (buffer (get-buffer seli/terminal-buffer-name))
         (process (and buffer (get-buffer-process buffer))))
    (if (and process (process-live-p process))
        buffer
      (eat-make "terminal" (or explicit-shell-file-name shell-file-name)))))

(defun seli/toggle-terminal ()
  "Toggle the dedicated terminal side window."
  (interactive)
  (let* ((buf (seli/get-or-create-terminal-buffer))
         (win (get-buffer-window buf t)))
    (if (and buf (get-buffer-window buf))
        (delete-window win)
      (select-window
       (display-buffer-in-side-window
        buf
        `((side . bottom)
          (slot . 0)
          (window-height . ,seli/terminal-window-height)
          (preserve-size . (nil . t))
          (dedicated . t)))))))

(use-package dape
  :commands (dape dape-breakpoint-toggle dape-repl)
  :config
  (setq dape-buffer-window-arrangement 'right))

;;; Final local customizations

(when (file-exists-p custom-file)
  (load custom-file nil t))

;;; init.el ends here
