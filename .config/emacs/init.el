;;; init.el --- Emacs Configuration -*- lexical-binding: t; -*-

;;; Commentary:
;; Minimal Emacs configuration focused on Evil mode and Org-mode
;; No coding features - optimized for note-taking and organization

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
;; 基本設定
;; ============================================================================

;; 行番号
(setq display-line-numbers-type 'relative)
(setq-default display-line-numbers-width 3)
(global-display-line-numbers-mode 1)

;; 空白文字の可視化
(setq whitespace-style '(face tabs tab-mark trailing))
(setq whitespace-display-mappings
      '((tab-mark ?\t [?› ?\t])
        (space-mark ?\  [?·])))
(global-whitespace-mode 1)

;; 折り返し設定
(setq-default truncate-lines nil)
(setq-default word-wrap t)
(setq visual-line-fringe-indicators '(nil right-curly-arrow))
(global-visual-line-mode 1)

;; クリップボード連携
(setq select-enable-clipboard t)
(setq select-enable-primary t)

;; GUI系の貼り付けキーを明示
(global-set-key (kbd "C-v") #'yank)
(global-set-key (kbd "C-S-v") #'yank)

;; Wayland/X11 の外部クリップボード連携を明示
(cond
 ;; Wayland: wl-copy / wl-paste
 ((and (getenv "WAYLAND_DISPLAY")
       (executable-find "wl-copy")
       (executable-find "wl-paste"))
  (setq interprogram-cut-function
        (lambda (text &optional _push)
          (let ((process-connection-type nil))
            (let ((proc (start-process "wl-copy" nil "wl-copy" "-f" "-n")))
              (process-send-string proc text)
              (process-send-eof proc)))))
  (setq interprogram-paste-function
        (lambda ()
          (let ((wl-paste (executable-find "wl-paste")))
            (when wl-paste
              (with-temp-buffer
                (call-process wl-paste nil t nil "-n")
                (when (> (buffer-size) 0)
                  (buffer-string))))))))
 ;; X11: xclip / xsel
 ((and (getenv "DISPLAY")
       (or (executable-find "xclip")
           (executable-find "xsel")))
  (let ((xclip (executable-find "xclip"))
        (xsel (executable-find "xsel")))
    (if xclip
        (progn
          (setq interprogram-cut-function
                (lambda (text &optional _push)
                  (let ((process-connection-type nil))
                    (let ((proc (start-process "xclip" nil "xclip" "-selection" "clipboard")))
                      (process-send-string proc text)
                      (process-send-eof proc)))))
          (setq interprogram-paste-function
                (lambda ()
                  (with-temp-buffer
                    (call-process "xclip" nil t nil "-selection" "clipboard" "-o")
                    (when (> (buffer-size) 0)
                      (buffer-string))))))
      (when xsel
        (setq interprogram-cut-function
              (lambda (text &optional _push)
                (let ((process-connection-type nil))
                  (let ((proc (start-process "xsel" nil "xsel" "--clipboard" "--input")))
                    (process-send-string proc text)
                    (process-send-eof proc)))))
        (setq interprogram-paste-function
              (lambda ()
                (with-temp-buffer
                  (call-process "xsel" nil t nil "--clipboard" "--output")
                  (when (> (buffer-size) 0)
                    (buffer-string))))))))))

;; タブとインデント
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

;; スクロールマージン
(setq scroll-margin 8)
(setq scroll-conservatively 100)

;; GUI要素を無効化
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; スタートアップメッセージを無効化
(setq inhibit-startup-message t)
(setq inhibit-splash-screen t)
(setq initial-scratch-message nil)

;; バックアップファイルを作らない
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

;; yes/no を y/n に
(defalias 'yes-or-no-p 'y-or-n-p)

;; 保存時に末尾の空白を削除
(add-hook 'before-save-hook 'delete-trailing-whitespace)

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
  ;; stateごとのカーソル形状
  (setq evil-normal-state-cursor '(box "orange"))
  (setq evil-insert-state-cursor '(bar "green"))
  (setq evil-visual-state-cursor '(hollow "cyan"))
  (setq evil-replace-state-cursor '(hbar "red"))
  (setq evil-motion-state-cursor '(box "purple"))
  (setq evil-emacs-state-cursor '(box "white"))
  (setq evil-operator-state-cursor '(hollow "yellow"))
  :config
  (evil-mode 1)

  ;; U でリドゥ
  (define-key evil-normal-state-map (kbd "U") 'evil-redo)

  ;; ビジュアルモードでインデント後も選択維持
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
(use-package general
  :ensure t
  :after evil
  :config
  (general-create-definer space-leader
    :states '(normal visual motion emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC"))

(elpaca-wait)

;; ============================================================================
;; テーマ & UI
;; ============================================================================

;; rose-pine テーマ
(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-moonlight t)
  ;; 背景を塗らず、端末側の透過背景を使う
  (set-face-background 'default "unspecified-bg" (selected-frame))
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

;; 背景透過（Wayland/X11対応）
(defvar my/buffer-alpha 96
  "Background opacity for buffer area (higher is more opaque).")

(defun my/set-frame-transparency (frame)
  "Set buffer-focused transparency for FRAME."
  (when (display-graphic-p frame)
    (condition-case err
        (progn
          (set-frame-parameter frame 'alpha-background my/buffer-alpha)
          (set-frame-parameter frame 'alpha '(100 . 100)))
      (error
       (message "transparency setup skipped: %s" (error-message-string err))))))

;; 新規フレーム向けのデフォルト値
(add-to-list 'default-frame-alist `(alpha-background . ,my/buffer-alpha))
(add-to-list 'default-frame-alist '(alpha . (100 . 100)))

(add-hook 'after-make-frame-functions #'my/set-frame-transparency)
;; 初期フレームにも適用
(when (display-graphic-p)
  (my/set-frame-transparency (selected-frame)))

;; モードライン
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

;; スムーズスクロール
(use-package smooth-scrolling
  :ensure t
  :config
  (smooth-scrolling-mode 1)
  (setq smooth-scroll-margin 8))

(elpaca-wait)

;; ============================================================================
;; Org-mode
;; ============================================================================

(use-package org
  :ensure t
  :mode ("\\.org\\'" . org-mode)
  :config
  ;; 基本設定
  (setq org-startup-indented t)            ; インデント表示
  (setq org-hide-leading-stars t)          ; 先頭の星を隠す
  (setq org-startup-folded 'overview)      ; 初期表示は折りたたみ
  (setq org-ellipsis " ▾")                 ; 折りたたみ記号
  
  ;; TODO設定
  (setq org-todo-keywords
        '((sequence "TODO(t)" "IN-PROGRESS(i)" "WAITING(w)" "|" "DONE(d)" "CANCELED(c)")))
  
  ;; タイムスタンプとログ
  (setq org-log-done 'time)                ; DONEにした時刻を記録
  (setq org-log-into-drawer t)             ; ログをdrawerに格納
  
  ;; アジェンダ設定
  (setq org-agenda-files '("~/org"))       ; アジェンダファイルのディレクトリ
  
  ;; ソースコードブロックのシンタックスハイライト
  (setq org-src-fontify-natively t)
  (setq org-src-tab-acts-natively t)
  (setq org-src-preserve-indentation t)
  (setq org-edit-src-content-indentation 0)
  
  ;; Babel - 実行可能な言語
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t))))

;; Org-modern - モダンなorg-modeスタイル
(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-star '("◉" "○" "✸" "✿" "✤" "✜" "◆" "▶"))
  (setq org-modern-table-vertical 1)
  (setq org-modern-table-horizontal 0.2)
  (setq org-modern-list '((43 . "➤") (45 . "–") (42 . "•")))
  (setq org-modern-block-fringe nil)
  (setq org-modern-todo-faces
        '(("TODO" :background "#ff6c6b" :foreground "#282c34")
          ("IN-PROGRESS" :background "#da8548" :foreground "#282c34")
          ("WAITING" :background "#ECBE7B" :foreground "#282c34")
          ("DONE" :background "#98be65" :foreground "#282c34")
          ("CANCELED" :background "#5B6268" :foreground "#282c34"))))

(elpaca-wait)

;; ============================================================================
;; 補完・ナビゲーション
;; ============================================================================

;; Vertico - ミニバッファ補完
(use-package vertico
  :ensure t
  :hook (after-init . vertico-mode)
  :config
  (setq vertico-cycle t)
  (setq vertico-count 15))

;; Orderless - フレキシブルなマッチング
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides '((file (styles partial-completion)))))

;; Marginalia - 補完候補に追加情報を表示
(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

;; Consult - 強化された検索・ナビゲーション
(use-package consult
  :ensure t
  :bind (("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("M-y" . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)))

(elpaca-wait)

;; ============================================================================
;; ユーティリティ
;; ============================================================================

;; Undo-tree（undo履歴の可視化）
(use-package undo-tree
  :ensure t
  :hook (after-init . global-undo-tree-mode)
  :config
  (setq undo-tree-auto-save-history nil)
  (evil-set-undo-system 'undo-tree))

;; Which-key（キーバインドヘルプ）
(use-package which-key
  :ensure t
  :hook (after-init . which-key-mode)
  :config
  (setq which-key-idle-delay 0.3)
  (setq which-key-prefix-prefix "+"))

;; 最近開いたファイル
(use-package recentf
  :ensure nil
  :hook (after-init . recentf-mode)
  :config
  (setq recentf-max-saved-items 200)
  (setq recentf-exclude '("/tmp/" "/ssh:" "/sudo:" "elpaca")))

;; ダッシュボード
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t)
  (setq dashboard-items '((recents . 10)
                          (bookmarks . 5)
                          (agenda . 5)))
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t))

;; bigfile対策
(defun my/check-large-file ()
  "Disable heavy modes for large files."
  (when (> (buffer-size) (* 1024 1024))  ; 1MB以上
    (fundamental-mode)
    (setq buffer-read-only t)
    (setq bidi-display-reordering nil)
    (jit-lock-mode nil)
    (buffer-disable-undo)))

(add-hook 'find-file-hook #'my/check-large-file)

(elpaca-wait)

;; ============================================================================
;; キーバインド
;; ============================================================================

(with-eval-after-load 'general
  (space-leader
    ;; ファイル・バッファ
    "f" 'find-file
    "b" 'consult-buffer
    "r" 'consult-recent-file
    
    ;; Org-mode
    "o a" 'org-agenda
    "o c" 'org-capture
    "o l" 'org-store-link
    
    ;; ユーティリティ
    "u" 'undo-tree-visualize
    "n" (lambda () (interactive) (evil-ex-nohighlight))
    
    ;; バッファ操作
    "k" 'kill-buffer
    "s" 'save-buffer))

;; グローバルキーバインド
(with-eval-after-load 'evil
  ;; 貼り付け（OSクリップボード）
  (define-key evil-insert-state-map (kbd "C-v") #'yank)
  (define-key evil-insert-state-map (kbd "C-S-v") #'yank))

;; エスケープでミニバッファをキャンセル
(define-key minibuffer-local-map (kbd "<escape>") 'keyboard-escape-quit)

;;; init.el ends here
