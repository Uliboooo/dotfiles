(message "✅ init.el loaded successfully.")
;; -------------------------------
;; パッケージ管理の初期設定
;; -------------------------------
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(setq use-package-always-ensure t)

;; -------------------------------
;; Vim キーバインド (evil-mode)
;; -------------------------------
(use-package evil
  :config
  (evil-mode 1)
  (setq evil-want-C-u-scroll t)
  (setq evil-normal-state-cursor '(box "orange"))
  (setq evil-insert-state-cursor '(bar "cyan"))
  (setq evil-visual-state-cursor '(hollow "gray")))
;;
;; line numbers
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative) ; relative numbers

(xterm-mouse-mode 1)

;; indent
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil) ; expandtab

(add-hook 'prog-mode-hook #'hs-minor-mode)

(setq-default truncate-lines t)

;; sharing clipboards
(setq select-enable-clipboard t)
;; mouse
(xterm-mouse-mode 1)

;; color theme (例: catppuccin)
(use-package catppuccin-theme
  :ensure t
  :config
  (load-theme 'catppuccin t))

;; list-chars 相当（whitespace-mode）
(require 'whitespace)
(setq whitespace-style '(face tabs spaces trailing space-mark tab-mark))
(setq whitespace-display-mappings
      '((space-mark ?\  [?·])
        (tab-mark ?\t [?» ?\t])
        (newline-mark ?\n [?$ ?\n])))
(global-whitespace-mode t)


(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package doom-modeline
  :init (doom-modeline-mode 1))

(use-package evil-nerd-commenter
  :bind ("C-c c" . evilnc-comment-or-uncomment-lines))

(use-package clipetty
  :hook (after-init . global-clipetty-mode))

(use-package alert
  :commands alert
  :config
  (setq alert-default-style 'notifications))


;; -------------------------------
;; SLIME + SBCL 設定（Common Lisp）
;; -------------------------------
(setq inferior-lisp-program "/usr/bin/sbcl") ;; ← SBCL のパスを環境に合わせて修正

(use-package slime
  :config
  (setq slime-contribs '(slime-fancy))
  (slime-setup))

;; -------------------------------
;; Parinfer（括弧＋インデント支援）
;; -------------------------------

;; old
;; (use-package parinfer
;;   :hook ((lisp-mode       . parinfer-mode)
;;          (slime-repl-mode . parinfer-mode))
;;   :config
;;   (setq parinfer-extensions
;;         '(defaults
;;           pretty-parens
;;           smart-tab
;;           smart-yank)))

;; (use-package parinfer-rust-mode
;;   :hook ((lisp-mode . parinfer-rust-mode)
;;          (emacs-lisp-mode . parinfer-rust-mode))
;;   :config
;;   (setq parinfer-rust-auto-download t))

(use-package rust-mode
             :ensure t
             :mode "\\.rs\\'")

;; lsp-mode (IDE機能のコア)
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (rust-mode . lsp-deferred) ; .rs ファイルを開いた時にLSPを起動
  :init
  ;; LSPが使うキーバインドのプレフィックス (例: C-c l r でリネーム)
  (setq lsp-keymap-prefix "C-c l"))

;; lsp-ui (情報表示をリッチにするUI)
(use-package lsp-ui
  :ensure t
  :hook (lsp-mode . lsp-ui-mode)
  :config
  ;; ドキュメントをカーソル位置に表示する
  (setq lsp-ui-doc-position 'at-point))

;; flycheck (エラーや警告をリアルタイムに表示)
;; (lsp-mode は flymake を推奨する傾向にありますが、flycheck も依然として強力です)
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode 1))

;; Rustファイル保存時に lsp-format-buffer を実行する
(defun my-rust-mode-hook ()
  "Custom settings for Rust mode."
  ;; 保存時に自動フォーマットを実行するフックを追加
  ;; 'nil t' は、このフックをバッファローカルにするためのおまじない
  (add-hook 'before-save-hook #'lsp-format-buffer nil t))

;; rust-mode が起動した時に、上記の関数を実行する
(add-hook 'rust-mode-hook #'my-rust-mode-hook)

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  ;; projectile が使うキーバインドのプレフィックス
  (setq projectile-keymap-prefix "C-c p"))

;; -------------------------------
;; paredit（括弧の構造編集）
;; -------------------------------
(use-package paredit
  :hook ((lisp-mode       . enable-paredit-mode)
         (slime-repl-mode . enable-paredit-mode)))

;; -------------------------------
;; lispy（超効率的なS式編集）
;; -------------------------------
(use-package lispy
  :hook ((lisp-mode       . lispy-mode)
         (slime-repl-mode . lispy-mode)))

;; -------------------------------
;; 保存時に自動整形（インデント）
;; -------------------------------
(defun my-lisp-auto-indent ()
  "保存時にバッファ全体をインデント"
  (when (or (eq major-mode 'lisp-mode)
            (eq major-mode 'slime-repl-mode))
    (indent-region (point-min) (point-max))))

(add-hook 'before-save-hook #'my-lisp-auto-indent)

;; -------------------------------
;; 補完・括弧カラー
;; -------------------------------
(use-package company
  :hook (after-init . global-company-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; -------------------------------
;; UI をスッキリ
;; -------------------------------
(menu-bar-mode -1)
(tool-bar-mode -1)
(setq inhibit-startup-screen t)

;; -------------------------------
;; カスタムファイルを別に保存
;; -------------------------------
(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file)
  (load custom-file))


;; (use-package sly
;;   :ensure t
;;   :config
;;   (setq inferior-lisp-program "sbcl"))

(use-package ivy
  :ensure t
  :diminish (ivy-mode . "") ; モードラインの表示をシンプルに
  :init
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t) ; 最近使ったファイルも候補に含める
  (setq ivy-count-format "(%d/%d) ") ; 候補数を表示
  ;; ファジー検索を有効にする (Helixの動作に最も近くなる)
  (setq ivy-re-builders-alist '((t . ivy--regex-fuzzy))))

(use-package counsel
  :ensure t
  :after ivy
  :bind (("M-x" . counsel-M-x) ("C-x C-f" . counsel-find-file)))


(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  ;; "C-c p" をプレフィックスとして設定（これは残してもOK）
  (setq projectile-keymap-prefix "C-c p")
  ;; --- 以下の :bind を追記 ---
  ;; "C-c f" が押されたら projectile-find-file を実行
  :bind (("C-c f" . projectile-find-file))
  )

