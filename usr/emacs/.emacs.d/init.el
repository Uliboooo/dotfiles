(load (expand-file-name "~/quicklisp/slime-helper.el"))

;; 使用するCommon Lisp処理系を指定（SBCLの場合）
(setq inferior-lisp-program "sbcl")

;; SLIMEの設定を必要に応じて追加
(require 'slime)
(slime-setup '(slime-fancy))  ;; fancy は補完やデバッガ機能を有効化

(xterm-mouse-mode 1)

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

;; rust
(add-to-list 'exec-path (expand-file-name "~/.cargo/bin//rust-analyzer"))
(add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))

(use-package rust-mode
             :ensure t
             :custom rust-format-on-save t)

(use-package cargo
             :ensure t
             :hook (rust-mode . cargo-minor-mode))

(use-package lsp-mode
             :ensure t
             :init (yas-global-mode)
             :hook (rust-mode . lsp)
             :bind ("C-c h" . hsp-desribe-thing-at-point)
             :custom (lsp-rust-server 'rust-analyzer))
(use-package lsp-ui
             :ensure t)

