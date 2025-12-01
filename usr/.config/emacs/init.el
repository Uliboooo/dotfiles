;; -----------------------------------------------------------------------------
;; pkg manager (MELPA)
;; -----------------------------------------------------------------------------
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))
(package-initialize)

;; use-packageがインストールされていなければ入れる (Emacs 28以下の場合)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; -----------------------------------------------------------------------------
;; basic config
;; -----------------------------------------------------------------------------

;; cleanup for ui
(setq inhibit-startup-message t)
;; (scroll-bar-mode -1)
;; (tool-bar-mode -1)
;; (tooltip-mode -1)
;; (menu-bar-mode -1)     ; メニューバーも消す
;; (set-fringe-mode 10)   ; 左右の余白

;; line-bumber (relative + absolute)
(column-number-mode)
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

;; 空白文字の表示 (listchars相当)
(require 'whitespace)
(setq whitespace-style '(face tabs tab-mark trailing space-before-tab::space))
(global-whitespace-mode t)

;; soft-wrap
(global-visual-line-mode t)

;; clipboard
(setq select-enable-clipboard t)
(setq select-enable-primary t)

;; indent setting
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil) ; expandtab

;; enable mouse seting
(xterm-mouse-mode 1)
(require 'mwheel)
(mouse-wheel-mode t)
(setq mouse-wheel-scroll-amount '(1 ((shift) . nil) ((control) . vertical)))
(setq mouse-wheel-progressive-speed nil)

;; auto update for files(autoread / checktime)
(global-auto-revert-mode 1)

;; don't create buckup files
(setq make-backup-files nil)
(setq auto-save-default nil)

;; -----------------------------------------------------------------------------
;; key-bind and vim emu
;; -----------------------------------------------------------------------------

;; Evil: vim control layer
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)

  ;; <leader>n でハイライト解除
  (define-key evil-normal-state-map (kbd "<leader>n") 'evil-ex-nohighlight))

;; Evil Collection: 様々なモードでVimキーを使えるようにする
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; General: キーバインド定義を簡単にする (vim.keymap.setの代替)
(use-package general
  :after evil
  :config
  (general-create-definer my-leader-def
    :prefix "SPC")

  (my-leader-def
    :states '(normal visual motion)
    "f"  '(consult-find :which-key "Find file")       ; Snacks picker files
    "/"  '(consult-ripgrep :which-key "Live grep")    ; fzf-lua live_grep
    "u"  '(vundo :which-key "Undo tree")              ; snacks picker undo (vundoで代替)
    "s"  '(consult-imenu :which-key "Symbols")        ; snacks symbols
    "b"  '(consult-buffer :which-key "Buffers")       ; バッファ切り替え

    ;; LSP
    "a"  '(eglot-code-actions :which-key "Code Action")
    "r"  '(eglot-rename :which-key "Rename")
    ;; "e"  '(consult-flymake :which-key "Diagnostics")  ; Troubleの代わり
    "gc" '(evilnc-comment-operator :which-key "Comment operator")

    ;;(my-leader-def
    ;;:states 'normal
    "ee"  '(slime-eval-last-expression :which-key "Eval last sexp")
    "er" '(slime-eval-defun :which-key "Eval defun")
    "eb" '(slime-eval-buffer :which-key "Eval buffer")))


;; C-c でコメントトングル
(use-package evil-nerd-commenter
  :bind ("C-c" . evilnc-comment-or-uncomment-lines))

;; -----------------------------------------------------------------------------
;; 4. 見た目・テーマ (visual.lua 相当)
;; -----------------------------------------------------------------------------

;; Catppuccin Theme
(use-package catppuccin-theme
  :config
  (load-theme 'catppuccin :no-confirm)
  (setq catppuccin-flavor 'macchiato)
  (unless (display-graphic-p) (set-face-background 'default "unspecified-bg")))

;; 透明化設定 (SnacksPickerやNormalFloatの透明化を再現)
;; Emacs 29+ では alpha-background が使えます
;; (set-frame-parameter nil 'alpha-background 0)
;; (add-to-list 'default-frame-alist '(alpha-background . 0))

(set-face-attribute 'font-lock-comment-face nil :foreground "#a5adcb")
(set-face-attribute 'font-lock-doc-face nil     :foreground "#a5adcb")

;; 2. 行番号 (Line Number) の背景を透明にする
(set-face-attribute 'line-number nil
                    :foreground "#e0e0e0"
                    :background "unspecified-bg")
(set-face-attribute 'line-number-current-line nil
                    :background "unspecified-bg")

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(doom-modeline-bar ((t (:background nil))))
 '(doom-modeline-panel ((t (:background nil))))
 '(mode-line ((t (:background nil :box nil))))
 '(mode-line-inactive ((t (:background nil :box nil)))))

;; Doom Modeline (lualineの代替)
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 25))

;; Rainbow Delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Git Signs (gitsigns.nvim 相当)
(use-package git-gutter
  :config
  (global-git-gutter-mode +1))

(setq inhibit-startup-message t)

;; (set-fringe-mode 10)
;; (set-face-attribute 'default nil :height 140)

;; -----------------------------------------------------------------------------
;; 5. 補完・検索・インターフェース (Snacks / fzf-lua 相当)
;; -----------------------------------------------------------------------------

;; Vertico: ミニバッファのUI拡張 (Telescope/Snacksのリスト部分)
(use-package vertico
  :init
  (vertico-mode))

;; Orderless: 曖昧検索 (fzfのような検索)
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

;; Marginalia: 補完候補に詳細情報を表示
(use-package marginalia
  :init
  (marginalia-mode))

;; Consult: 検索コマンド集 (ripgrep, find, bufferなど)
(use-package consult)

;; Vundo: アンドゥツリーの可視化
(use-package vundo)

;; -----------------------------------------------------------------------------
;; 6. LSP & 補完 & フォーマット (lsp.lua / conform.lua 相当)
;; -----------------------------------------------------------------------------

;; Eglot: 軽量LSPクライアント (Built-in in Emacs 29)
(use-package eglot
  :hook ((go-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (c-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (python-mode . eglot-ensure)
         (js-mode . eglot-ensure))
  :config
  ;; Inlay Hints (vim.lsp.inlay_hint)
  (add-hook 'eglot-managed-mode-hook (lambda () (eglot-inlay-hints-mode 1)))

  ;; キーマップ (gr -> references)
  (define-key evil-normal-state-map (kbd "gr") 'xref-find-references)
  (define-key evil-normal-state-map (kbd "gd") 'xref-find-definitions)
  (define-key evil-normal-state-map (kbd "K") 'eldoc))

;; Corfu: 補完ポップアップ (nvim-cmp 相当)
(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.0)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  :bind (:map corfu-map
              ("<tab>" . corfu-next)
              ("<backtab>" . corfu-previous)))

;; Apheleia: 自動フォーマット (conform.nvim 相当)
(use-package apheleia
  :config
  (apheleia-global-mode +1))

;; Treesitter (Emacs 29+ built-in, or separate package)
(use-package treesit-auto
  :config
  (global-treesit-auto-mode))

;; Auto Pairs (nvim-autopairs 相当)
(use-package smartparens
  :hook (prog-mode . smartparens-mode))

;; -----------------------------------------------------------------------------
;; Lang (Go, Rust, Lisp, Markdown)
;; -----------------------------------------------------------------------------

;; Go
(use-package go-mode
  :hook (go-mode . (lambda ()
                     (setq tab-width 2)
                     (setq indent-tabs-mode t))))

;; Rust
(use-package rust-mode)

;; Markdown (md.lua)
(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown"))

;; Lisp / SBCL (sbcl.lua, slime.lua)
;; nvimでは vlime/conjure でしたが、Emacsなら Slime か Sly が標準的です。
;; ここでは tmux との連携も考慮し、最も強力な Slime を設定します。

(use-package slime
  :config
  (setq inferior-lisp-program "sbcl") ; SBCLを指定
  (setq slime-contribs '(slime-fancy)))

;; キーバインド (config.lua の Conjure/Slime 設定に近いもの)

;; -----------------------------------------------------------------------------
;; others
;; -----------------------------------------------------------------------------

;; Vterm: 高機能ターミナル (toggletermの代替として最強)
;; 注: コンパイルが必要です (CMake, libvterm)
(use-package vterm
  :commands vterm
  :config
  (setq vterm-shell "zsh"))

(use-package vterm-toggle
  :bind ("C-\\" . vterm-toggle))

;; only using GUI
(when (display-graphic-p)
  ;; only gui
  (set-frame-font "0xProto Nerd Font-11" t t) ;
  (add-to-list 'default-frame-alist '(alpha-background . 80))
  (set-frame-parameter nil 'alpha-background 80)
  (tooltip-mode 1)
  (set-fringe-mode 2))


;; git
(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
