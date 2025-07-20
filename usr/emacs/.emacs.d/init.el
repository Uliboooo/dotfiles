(load (expand-file-name "~/quicklisp/slime-helper.el"))

;; 使用するCommon Lisp処理系を指定（SBCLの場合）
(setq inferior-lisp-program "sbcl")

;; SLIMEの設定を必要に応じて追加
(require 'slime)
(slime-setup '(slime-fancy))  ;; fancy は補完やデバッガ機能を有効化

