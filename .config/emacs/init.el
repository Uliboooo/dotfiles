;;; init.el --- Emacs Configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Neovimから移行したEmacs設定
;; Evil mode (Vim keybindings) + elpaca パッケージマネージャー

;;; Code:

;; ============================================================================
;; Elpaca パッケージマネージャー
;; ============================================================================

(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; use-package統合
(elpaca elpaca-use-package
  (elpaca-use-package-mode))
(setq elpaca-use-package-by-default t)

;; Elpacaの完了を待つ
(elpaca-wait)

;; ============================================================================
;; 基本設定（nvim/config.luaから移行）
;; ============================================================================

;; 行番号
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; 空白文字の可視化（list, listchars）
(setq whitespace-style '(face tabs tab-mark trailing))
(setq whitespace-display-mappings
      '((tab-mark ?\t [?› ?\t])
        (space-mark ?\  [?·])))
(global-whitespace-mode 1)

;; 折り返し設定（wrap, linebreak, breakindent）
(setq-default truncate-lines nil)
(setq-default word-wrap t)
(setq visual-line-fringe-indicators '(nil right-curly-arrow))
(global-visual-line-mode 1)

;; クリップボード連携（clipboard = unnamedplus）
(setq select-enable-clipboard t)

;; 検索ハイライト（hlsearch）
(setq isearch-lazy-highlight t)

;; インデント設定（tabstop, shiftwidth, expandtab）
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(setq-default standard-indent 2)

;; TrueColor（termguicolors）
(setq-default frame-background-mode 'dark)

;; カーソル行ハイライト（cursorline）
(global-hl-line-mode 1)

;; マウス対応（mouse = "a"）
(xterm-mouse-mode 1)

;; サインカラム（signcolumn = "yes"）
(setq-default left-fringe-width 8)
(setq-default right-fringe-width 8)

;; ファイル自動リロード（autoread）
(global-auto-revert-mode 1)
(setq auto-revert-interval 1)

;; その他の基本設定
(setq-default fill-column 100)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)
(setq ring-bell-function 'ignore)
(setq use-short-answers t)
(setq confirm-kill-emacs 'y-or-n-p)
(setq scroll-margin 8)
(setq scroll-conservatively 101)
(pixel-scroll-precision-mode 1)

;; UTF-8
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)

;; フォント設定（HiDPI / Wayland 4K x1.5 対応）
(defun my/setup-fonts ()
  "Setup fonts for HiDPI displays."
  (when (display-graphic-p)
    ;; メインフォント - XLFD形式で明示的に指定
    (set-face-attribute 'default nil
                        :font "0xProto-14"
                        :weight 'regular)
    ;; 固定幅フォント
    (set-face-attribute 'fixed-pitch nil
                        :font "0xProto-14")
    ;; 可変幅フォント
    (set-face-attribute 'variable-pitch nil
                        :font "Noto Sans-14")
    ;; 日本語フォント
    (dolist (charset '(kana han cjk-misc bopomofo))
      (set-fontset-font t charset
                        (font-spec :family "Noto Sans CJK JP" :size 14)))
    ;; 絵文字
    (set-fontset-font t 'emoji
                      (font-spec :family "Noto Color Emoji") nil 'prepend)
    ;; 記号類
    (set-fontset-font t 'symbol
                      (font-spec :family "Noto Sans Symbols 2") nil 'prepend)))

;; GUIフレーム作成時にフォント設定を適用
(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'my/setup-fonts)
  (my/setup-fonts))

;; ============================================================================
;; Evil Mode（Vim keybindings）
;; ============================================================================

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-undo-system 'undo-redo)
  (setq evil-search-module 'isearch)
  :config
  (evil-mode 1)
  
  ;; U でリドゥ（nvim: vim.keymap.set("n", "U", "<C-r>")）
  (define-key evil-normal-state-map (kbd "U") 'evil-redo)
  
  ;; ビジュアルモードでインデント後も選択維持（nvim: >gv, <gv）
  (define-key evil-visual-state-map (kbd ">") (lambda ()
    (interactive)
    (evil-shift-right (region-beginning) (region-end))
    (evil-visual-restore)))
  (define-key evil-visual-state-map (kbd "<") (lambda ()
    (interactive)
    (evil-shift-left (region-beginning) (region-end))
    (evil-visual-restore))))

(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init))

;; Leader key（Space）
(use-package evil-leader
  :ensure t
  :after evil
  :config
  (global-evil-leader-mode)
  (evil-leader/set-leader "<SPC>"))

(elpaca-wait)

;; ============================================================================
;; テーマ & UI（nvim/visual.luaから移行）
;; ============================================================================

;; rose-pine テーマ
(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  ;; nvimではrose-pine-moonを使用、Emacsではdoom-moonlightが近い
  (load-theme 'doom-moonlight t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;; 背景透過（Wayland/X11対応）
(defun my/set-frame-transparency (frame)
  "Set transparency for FRAME."
  (set-frame-parameter frame 'alpha-background 85))

(add-hook 'after-make-frame-functions #'my/set-frame-transparency)
;; 初期フレームにも適用
(when (display-graphic-p)
  (my/set-frame-transparency (selected-frame)))

;; モードライン（lualine相当）
(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode)
  :config
  (setq doom-modeline-height 28)
  (setq doom-modeline-buffer-file-name-style 'relative-from-project)
  (setq doom-modeline-icon t)
  (setq doom-modeline-major-mode-icon t)
  (setq doom-modeline-buffer-modification-icon t)
  (setq doom-modeline-vcs-max-length 20))

;; アイコン
(use-package nerd-icons
  :ensure t)

;; Git差分表示（gitsigns相当）
(use-package diff-hl
  :ensure t
  :hook ((after-init . global-diff-hl-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (setq diff-hl-draw-borders nil)
  (diff-hl-flydiff-mode 1))

;; 括弧のレインボーカラー（rainbow-delimiters相当）
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

;; インデントガイド（snacks.indent相当）
(use-package highlight-indent-guides
  :ensure t
  :hook (prog-mode . highlight-indent-guides-mode)
  :config
  (setq highlight-indent-guides-method 'character)
  (setq highlight-indent-guides-character ?│)
  (setq highlight-indent-guides-responsive 'top))

;; 折りたたみ（nvim-ufo相当）
(use-package origami
  :ensure t
  :hook (prog-mode . origami-mode)
  :config
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "za") 'origami-toggle-node)
    (define-key evil-normal-state-map (kbd "zR") 'origami-open-all-nodes)
    (define-key evil-normal-state-map (kbd "zM") 'origami-close-all-nodes)
    (define-key evil-normal-state-map (kbd "zo") 'origami-open-node)
    (define-key evil-normal-state-map (kbd "zc") 'origami-close-node)))

;; スムーズスクロール（snacks.scroll相当）
(use-package smooth-scrolling
  :ensure t
  :config
  (smooth-scrolling-mode 1)
  (setq smooth-scroll-margin 8))

;; ワードハイライト（snacks.words相当）
(use-package symbol-overlay
  :ensure t
  :hook (prog-mode . symbol-overlay-mode)
  :bind (:map symbol-overlay-mode-map
         ("M-i" . symbol-overlay-put)
         ("M-n" . symbol-overlay-jump-next)
         ("M-p" . symbol-overlay-jump-prev)))

;; 現在行のgit blame表示（gitsigns current_line_blame相当）
(use-package blamer
  :ensure t
  :hook (prog-mode . blamer-mode)
  :config
  (setq blamer-idle-time 0.3)
  (setq blamer-min-offset 40)
  (setq blamer-prettify-time-p t)
  (setq blamer-author-formatter "%s, ")
  (setq blamer-datetime-formatter "%Y-%m-%d")
  (setq blamer-commit-formatter " - %s"))

(elpaca-wait)

;; ============================================================================
;; 補完システム（blink.cmp相当）
;; ============================================================================

;; Corfu（補完UI）
(use-package corfu
  :ensure t
  :hook ((prog-mode . corfu-mode)
         (shell-mode . corfu-mode)
         (eshell-mode . corfu-mode))
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :bind (:map corfu-map
         ("TAB" . corfu-next)
         ([tab] . corfu-next)
         ("S-TAB" . corfu-previous)
         ([backtab] . corfu-previous)
         ("RET" . corfu-insert)))

;; Cape（補完ソース）
(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

;; Orderless（補完マッチング）
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

;; Marginalia（補完に説明を追加）
(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

;; スニペット
(use-package yasnippet
  :ensure t
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

(elpaca-wait)

;; ============================================================================
;; ファジーファインダー（snacks.nvim picker相当）
;; ============================================================================

;; Vertico（ミニバッファ補完UI）
(use-package vertico
  :ensure t
  :hook (after-init . vertico-mode)
  :custom
  (vertico-cycle t)
  (vertico-resize nil)
  (vertico-count 17))

;; Consult（検索コマンド）
(use-package consult
  :ensure t
  :bind (("C-x b" . consult-buffer)
         ("M-g g" . consult-goto-line)
         ("M-g i" . consult-imenu)
         ("M-s f" . consult-fd)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line))
  :config
  ;; リアルタイム検索設定
  (setq consult-async-min-input 1)
  (setq consult-async-input-debounce 0.1)
  (setq consult-async-input-throttle 0.2)
  
  ;; fd設定（hidden files表示、nvimと同じ除外パターン）
  (setq consult-fd-args
        '((if (executable-find "fdfind" 'remote) "fdfind" "fd")
          "--full-path --color=never --hidden"
          "--exclude .git"
          "--exclude node_modules"
          "--exclude target"
          "--exclude .mooncakes"
          "--exclude eln-cache"
          "--exclude elpaca"))
  
  ;; ripgrep設定（hidden files表示）
  (setq consult-ripgrep-args
        "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --with-filename --line-number --search-zip --hidden --glob !.git/ --glob !node_modules/ --glob !target/ --glob !.mooncakes/"))

;; Embark（コンテキストアクション）
(use-package embark
  :ensure t
  :bind (("C-." . embark-act)
         ("M-." . embark-dwim)
         ("C-h B" . embark-bindings))
  :config
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :ensure t
  :after (embark consult))

(elpaca-wait)

;; ============================================================================
;; LSP設定（eglot - Emacs内蔵）
;; nvim/lsp.luaから移行
;; ============================================================================

;; Flymake（診断 - Emacs内蔵）
(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :config
  (setq flymake-no-changes-timeout 0.5))

;; Eglot（LSPクライアント - Emacs内蔵）
(use-package eglot
  :ensure nil
  :hook ((rust-mode rust-ts-mode) . eglot-ensure)
  :hook ((typescript-mode typescript-ts-mode) . eglot-ensure)
  :hook ((js-mode js-ts-mode) . eglot-ensure)
  :hook ((go-mode go-ts-mode) . eglot-ensure)
  :hook ((c-mode c++-mode c-ts-mode c++-ts-mode) . eglot-ensure)
  :hook ((python-mode python-ts-mode) . eglot-ensure)
  :hook (zig-mode . eglot-ensure)
  :hook (lua-mode . eglot-ensure)
  :hook ((html-mode css-mode) . eglot-ensure)
  :hook (markdown-mode . eglot-ensure)
  :config
  ;; インレイヒント有効化
  (setq eglot-ignored-server-capabilities nil)
  (add-hook 'eglot-managed-mode-hook
            (lambda () (eglot-inlay-hints-mode 1)))
  
  ;; LSPサーバー設定（nvimと同様）
  (add-to-list 'eglot-server-programs
               '(rust-mode rust-ts-mode . ("rust-analyzer" :initializationOptions
                 (:cargo (:allFeatures t)
                  :check (:command "clippy")
                  :inlayHints (:enable t :typeHints t :parameterHints t)))))
  (add-to-list 'eglot-server-programs
               '((typescript-mode typescript-ts-mode) . ("typescript-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((go-mode go-ts-mode) . ("gopls")))
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode c-ts-mode c++-ts-mode) . ("clangd")))
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("basedpyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(zig-mode . ("zls")))
  (add-to-list 'eglot-server-programs
               '(lua-mode . ("lua-language-server")))
  (add-to-list 'eglot-server-programs
               '(markdown-mode . ("marksman"))))

;; consult-eglot
(use-package consult-eglot
  :ensure t
  :after (consult eglot))

(elpaca-wait)

;; ============================================================================
;; コードフォーマット（conform.nvim相当）
;; ============================================================================

(use-package apheleia
  :ensure t
  :hook (after-init . apheleia-global-mode)
  :config
  ;; nvim conform.nvmと同様のフォーマッター設定
  (setf (alist-get 'rustfmt apheleia-formatters) '("rustfmt" "--edition" "2021"))
  (setf (alist-get 'gofmt apheleia-formatters) '("gofmt"))
  (setf (alist-get 'stylua apheleia-formatters) '("stylua" "-"))
  (setf (alist-get 'biome apheleia-formatters) '("biome" "format" "--stdin-file-path" filepath))
  (setf (alist-get 'shfmt apheleia-formatters) '("shfmt" "-i" "2"))
  
  ;; ファイルタイプとフォーマッターのマッピング
  (setf (alist-get 'rust-mode apheleia-mode-alist) 'rustfmt)
  (setf (alist-get 'rust-ts-mode apheleia-mode-alist) 'rustfmt)
  (setf (alist-get 'go-mode apheleia-mode-alist) 'gofmt)
  (setf (alist-get 'go-ts-mode apheleia-mode-alist) 'gofmt)
  (setf (alist-get 'lua-mode apheleia-mode-alist) 'stylua)
  (setf (alist-get 'json-mode apheleia-mode-alist) 'biome)
  (setf (alist-get 'json-ts-mode apheleia-mode-alist) 'biome)
  (setf (alist-get 'sh-mode apheleia-mode-alist) 'shfmt))

;; ============================================================================
;; 編集支援（nvim/edit.luaから移行）
;; ============================================================================

;; 自動括弧補完（nvim-autopairs相当）
(use-package smartparens
  :ensure t
  :hook (prog-mode . smartparens-mode)
  :config
  (require 'smartparens-config))

;; 自動タグ補完（nvim-ts-autotag相当）
(use-package web-mode
  :ensure t
  :mode ("\\.html\\'" "\\.tsx\\'" "\\.jsx\\'" "\\.astro\\'")
  :config
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-enable-auto-pairing t)
  (setq web-mode-enable-auto-closing t))

;; コメントトグル（Comment.nvim相当）
;; evil-nerd-commenter
(use-package evil-nerd-commenter
  :ensure t
  :after evil)

;; ============================================================================
;; Git統合（magit）
;; ============================================================================

;; transient を最新版にアップグレード（magit が 0.12+ を要求）
(use-package transient
  :ensure t)

(elpaca-wait)

(use-package magit
  :ensure t
  :after transient
  :commands (magit-status magit-blame)
  :config
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(elpaca-wait)

;; ============================================================================
;; ターミナル（toggleterm相当）
;; ============================================================================

(use-package vterm
  :ensure t
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000)
  (setq vterm-shell (or (executable-find "fish")
                        (executable-find "zsh")
                        (executable-find "bash"))))

;; vterm-toggle（toggleterm風の動作）
(use-package vterm-toggle
  :ensure t
  :bind (("C-\\" . vterm-toggle)
         ("C-_" . vterm-toggle-cd))
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  ;; 下部に20行で表示
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                   (let ((buffer (get-buffer buffer-or-name)))
                     (with-current-buffer buffer
                       (or (equal major-mode 'vterm-mode)
                           (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 (reusable-frames . visible)
                 (window-height . 0.3))))

;; ============================================================================
;; Tree-sitter（Emacs 29+内蔵）
;; ============================================================================

(when (treesit-available-p)
  (setq treesit-font-lock-level 4)
  
  ;; 言語モードの自動マッピング
  (setq major-mode-remap-alist
        '((c-mode . c-ts-mode)
          (c++-mode . c++-ts-mode)
          (python-mode . python-ts-mode)
          (javascript-mode . js-ts-mode)
          (typescript-mode . typescript-ts-mode)
          (json-mode . json-ts-mode)
          (css-mode . css-ts-mode)
          (yaml-mode . yaml-ts-mode)
          (rust-mode . rust-ts-mode)
          (go-mode . go-ts-mode)
          (bash-mode . bash-ts-mode))))

;; ============================================================================
;; 言語サポート
;; ============================================================================

(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'")

(use-package go-mode
  :ensure t
  :mode "\\.go\\'")

(use-package zig-mode
  :ensure t
  :mode "\\.zig\\'")

(use-package lua-mode
  :ensure t
  :mode "\\.lua\\'"
  :config
  (setq lua-indent-level 2))

(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" "\\.markdown\\'"))

(use-package yaml-mode
  :ensure t
  :mode ("\\.yml\\'" "\\.yaml\\'"))

(use-package json-mode
  :ensure t
  :mode ("\\.json\\'" "\\.jsonc\\'"))

;; MoonBit（nvimのカスタムfiletype）
(add-to-list 'auto-mode-alist '("\\.mbt\\'" . prog-mode))

;; TypeScriptモード
(use-package typescript-mode
  :ensure t
  :mode ("\\.ts\\'" "\\.tsx\\'")
  :config
  (setq typescript-indent-level 2))

;; Astroモード
(use-package astro-ts-mode
  :ensure t
  :mode "\\.astro\\'")

(elpaca-wait)

;; ============================================================================
;; キーバインド（nvim/keymap.luaから移行）
;; ============================================================================

(with-eval-after-load 'evil-leader
  (evil-leader/set-key
    ;; ファイル・検索（snacks.nvim相当）
    "f" 'consult-fd              ; <Leader>f - ファイル検索
    "/" 'consult-ripgrep         ; <Leader>/ - Grep検索
    "b" 'consult-buffer          ; <Leader>b - バッファ切り替え（追加）
    "m" 'consult-mark            ; <Leader>m - マーク検索
    "u" 'undo-tree-visualize     ; <Leader>u - Undo履歴（snacks.undo相当）
    "d" 'consult-flymake         ; <Leader>d - 診断一覧
    "s" 'consult-eglot-symbols   ; <Leader>s - LSPシンボル
    
    ;; LSP関連
    "a" 'eglot-code-actions      ; <Leader>a - コードアクション
    "r" 'eglot-rename            ; <Leader>r - リネーム
    
    ;; 検索ハイライト解除
    "n" (lambda () (interactive) (evil-ex-nohighlight))
    
    ;; Git（<Leader>l = lazygit相当だが、Emacsではmagit）
    "g" 'magit-status
    "l" 'magit-log-current
    
    ;; コメントトグル
    "c" 'evilnc-comment-or-uncomment-lines))

;; グローバルキーバインド
(with-eval-after-load 'evil
  ;; C-s で保存（nvim: <C-s> = :w）
  (define-key evil-normal-state-map (kbd "C-s") 'save-buffer)
  (define-key evil-insert-state-map (kbd "C-s") 'save-buffer)
  
  ;; C-c でコメントトグル
  (define-key evil-normal-state-map (kbd "C-c") 'evilnc-comment-or-uncomment-lines)
  (define-key evil-visual-state-map (kbd "C-c") 'evilnc-comment-or-uncomment-lines)
  
  ;; gd で定義へジャンプ
  (define-key evil-normal-state-map (kbd "g d") 'xref-find-definitions)
  
  ;; gr で参照検索
  (define-key evil-normal-state-map (kbd "g r") 'xref-find-references)
  
  ;; K でホバー情報
  (define-key evil-normal-state-map (kbd "K") 'eldoc-doc-buffer))

;; ターミナルトグル（C-\）
(global-set-key (kbd "C-\\") 'vterm)

;; ============================================================================
;; Which-key（キーバインドヘルプ）
;; ============================================================================

(use-package which-key
  :ensure t
  :hook (after-init . which-key-mode)
  :config
  (setq which-key-idle-delay 0.3)
  (setq which-key-prefix-prefix "+"))

;; ============================================================================
;; 追加の便利機能
;; ============================================================================

;; プロジェクト管理（project.el - Emacs内蔵）
(use-package project
  :ensure nil
  :config
  (setq project-switch-commands
        '((project-find-file "Find file")
          (consult-ripgrep "Ripgrep")
          (project-dired "Dired"))))

;; 最近開いたファイル
(use-package recentf
  :ensure nil
  :hook (after-init . recentf-mode)
  :config
  (setq recentf-max-saved-items 200)
  (setq recentf-exclude '("/tmp/" "/ssh:" "/sudo:" "elpaca")))

;; Undo-tree（undo履歴の可視化）
(use-package undo-tree
  :ensure t
  :hook (after-init . global-undo-tree-mode)
  :config
  (setq undo-tree-auto-save-history nil)
  (evil-set-undo-system 'undo-tree))

;; 危険な文字のハイライト（nvimのDangerousChars相当）
(defface dangerous-chars-face
  '((t (:background "red")))
  "Face for dangerous invisible characters.")

(defun highlight-dangerous-chars ()
  "Highlight dangerous invisible Unicode characters."
  (font-lock-add-keywords
   nil
   '(("[\u200B\u200C\u200D\uFEFF\u202E\u2066-\u2069]" 0 'dangerous-chars-face t))))

(add-hook 'prog-mode-hook #'highlight-dangerous-chars)

;; ダッシュボード（snacks.dashboard相当）
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t)
  (setq dashboard-items '((recents . 10)
                          (projects . 5)
                          (bookmarks . 5)))
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t))

;; 通知（snacks.notifier相当）
(use-package alert
  :ensure t
  :config
  (setq alert-default-style 'libnotify))

;; 入力補助（snacks.input相当）
(use-package vertico-posframe
  :ensure t
  :after vertico
  :config
  (vertico-posframe-mode 1)
  (setq vertico-posframe-parameters
        '((left-fringe . 8)
          (right-fringe . 8))))

;; bigfile対策（snacks.bigfile相当）
(defun my/check-large-file ()
  "Disable heavy modes for large files."
  (when (> (buffer-size) (* 1024 1024))  ; 1MB以上
    (fundamental-mode)
    (setq buffer-read-only t)
    (setq bidi-display-reordering nil)
    (jit-lock-mode nil)
    (buffer-disable-undo)))

(add-hook 'find-file-hook #'my/check-large-file)

;; scope（snacks.scope相当 - 関数スコープのハイライト）
(use-package treesit-fold
  :ensure (:host github :repo "emacs-tree-sitter/treesit-fold")
  :after tree-sitter
  :config
  (global-treesit-fold-mode))

;; Quickfix相当（compile結果のナビゲーション）
(use-package compile
  :ensure nil
  :config
  (setq compilation-scroll-output t)
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "]q") 'next-error)
    (define-key evil-normal-state-map (kbd "[q") 'previous-error)))

;; LSP診断のナビゲーション（nvimの]d, [d相当）
(with-eval-after-load 'evil
  (define-key evil-normal-state-map (kbd "]d") 'flymake-goto-next-error)
  (define-key evil-normal-state-map (kbd "[d") 'flymake-goto-prev-error)
  ;; Git hunk ナビゲーション（gitsigns相当）
  (define-key evil-normal-state-map (kbd "]c") 'diff-hl-next-hunk)
  (define-key evil-normal-state-map (kbd "[c") 'diff-hl-previous-hunk))

;; Git preview（C-pでhunkプレビュー - nvimの<C-p>相当）
(with-eval-after-load 'diff-hl
  (global-set-key (kbd "C-c p") 'diff-hl-show-hunk))

;; エスケープでミニバッファをキャンセル
(define-key minibuffer-local-map (kbd "<escape>") 'keyboard-escape-quit)

;; 保存時に末尾の空白を削除
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; 自動保存を無効化（nvim同様）
(setq auto-save-default nil)
(setq create-lockfiles nil)

;; 診断コピー（nvimのdcキーマップ相当）
(defun my/copy-diagnostic-at-point ()
  "Copy diagnostic message at point to clipboard."
  (interactive)
  (let ((diag (flymake-diagnostics (point))))
    (when diag
      (let* ((d (car diag))
             (msg (flymake-diagnostic-text d)))
        (kill-new msg)
        (message "Diagnostic copied: %s" msg)))))

(with-eval-after-load 'evil-leader
  (evil-leader/set-key
    "D" 'my/copy-diagnostic-at-point))

;;; init.el ends here
