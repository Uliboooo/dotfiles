;; pkg manager
(require 'package)

(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; (use-package catppuccin-theme
;;   :ensure t
;;   :config
;;   (load-theme 'catppuccin-macchiato :no-confirm))

;; about rust config
(use-package rust-mode
  :hook (rust-mode . lsp))

(use-package lsp-mode
  :hook (prog-mode . lsp)
  :commands lsp
  :custom
  (lsp-rust-analyzer-server-command '("rust-analyzer")))

(with-eval-after-load 'lsp-mode
  (define-key lsp-mode-map (kbd "M-RET") 'lsp-execute-code-action))

(use-package lsp-ui
  :commands lsp-ui-mode)

(use-package cargo
  :hook (rust-mode . cargo-minor-mode))

(use-package flycheck
  :init (global-flycheck-mode))

;; line number
(setq display-line-numbers-type 'relative) ;; always show line num
(global-display-line-numbers-mode t)
(setq-default indent-tabs-mode nil tab-width 4) ;; tab size 4
(global-hl-line-mode 1) ;; hiright current line
;; (display-line-numbers-type 'relative) ;; relative line num

(use-package hideshow
  :hook (prog-mode . hs-minor-mode))

(use-package treemacs  ;; show project struct in sidebar
             :defer t) ;; lazy laod

(use-package smartparens
             :hook (prog-mode . smartparens-mode))
(electric-pair-mode 1)

;; toggle comments
(use-package rainbow-delimiters
             :hook (prog-mode . rainbow-delimiters-mode)) ;; colors for each deeps

(use-package company
             :hook (after-init . global-company-mode))

;; (use-package yasnippet
;;              :hook (prog-mode . yas-minor-mode))
;;
;; (use-package doom-modeline
;;              :hook (after-init . doom-modeline-mode))


;; (use-package yasnippet
;;   ;; :ensure t
;;   :init (yas-global-mode 1))


(use-package doom-modeline
             :ensure t
             :hook (after-init . doom-modeline-mode))
;; (use-package crates
;;              :hook (toml-mode . crates-mode))

;; (use-package vterm
;;              :ensure t)
