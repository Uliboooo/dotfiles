;;; early-init.el --- Early Init File -*- lexical-binding: t; -*-

;;; Commentary:
;; Emacs 27+ の起動最適化
;; このファイルはパッケージシステムやUIが初期化される前に実行される

;;; Code:

;; GCを一時的に無効化して起動を高速化
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; 起動後にGC設定を適切な値に調整
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)  ; 16MB
                  gc-cons-percentage 0.1)))

;; アイドル時のGC
(run-with-idle-timer 5 t #'garbage-collect)

;; パッケージシステムを無効化（elpacaを使用するため）
(setq package-enable-at-startup nil)

;; ネイティブコンパイル設定（Emacs 28+）
(when (featurep 'native-compile)
  (setq native-comp-async-report-warnings-errors nil
        native-comp-deferred-compilation t
        native-comp-speed 2))

;; UI要素を早期に無効化（フレーム作成前）
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; HiDPI / Wayland スケーリング対応
;; 4K x1.5 スケーリング環境用
(setq frame-resize-pixelwise t)
(setq window-resize-pixelwise t)

;; フォントレンダリング改善
(setq x-gtk-use-native-input t)

;; Xftフォント設定（アンチエイリアス、ヒンティング）
(push '(font-backend . (x ftcrhb)) default-frame-alist)

;; フォントのサブピクセルレンダリング
(setq cairo-antialias-type 'best)

;; X resources でのフォント設定を無視（Emacs側で制御）
(setq inhibit-x-resources t)

;; ファイルハンドラーを一時的に無効化
(defvar my/file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist my/file-name-handler-alist-original)))

;; 起動メッセージを無効化
(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t
      initial-scratch-message nil)

;; サイト設定ファイルをロードしない
(setq site-run-file nil)

;; 警告を抑制
(setq byte-compile-warnings '(not obsolete))
(setq warning-suppress-log-types '((comp) (bytecomp)))
(setq warning-suppress-types '((elpaca) (emacs)))

;;; early-init.el ends here
