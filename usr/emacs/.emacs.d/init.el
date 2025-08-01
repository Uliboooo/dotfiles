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
  (setq evil-want-C-u-scroll t))

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

(use-package parinfer-rust-mode
  :hook ((lisp-mode . parinfer-rust-mode)
         (emacs-lisp-mode . parinfer-rust-mode))
  :config
  (setq parinfer-rust-auto-download t))

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
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)
(load-theme 'tango-dark t)

;; -------------------------------
;; カスタムファイルを別に保存
;; -------------------------------
(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file)
  (load custom-file))

