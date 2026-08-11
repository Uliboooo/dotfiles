# Emacs init.el 解説

対象ファイル: `.config/emacs/init.el`

この設定は、Emacs を Vim 風の操作体系に寄せたうえで、**org mode で文章とノートを書くこと**に用途を絞っている。LSP、診断、フォーマッタ、デバッガ、各言語の major mode、Git クライアント、端末は持たない。状態ファイルやキャッシュは XDG ディレクトリに逃がし、設定ディレクトリを汚しにくくしている。

## 1. ファイル先頭と基本ロード設定

```elisp
;;; init.el --- Seli Emacs config -*- lexical-binding: t; -*-
```

`lexical-binding: t` は Emacs Lisp の変数スコープを lexical scope にする指定。関数内で作ったローカル変数がクロージャとして安全に扱いやすくなり、現代的な Emacs Lisp ではほぼ標準の書き方。

```elisp
(require 'package)
```

`package` は Emacs 標準のパッケージ管理機能。

## 2. コンパイル警告を起動時に出さない設定

```elisp
(setq native-comp-async-report-warnings-errors 'silent
      byte-compile-warnings '(not obsolete free-vars unresolved noruntime lexical make-local)
      warning-suppress-types '((bytecomp) (comp) (native-compiler))
      warning-suppress-log-types '((bytecomp) (comp) (native-compiler)))
```

ネイティブコンパイルやバイトコンパイルの警告を、起動時 UI に出にくくしている。サードパーティパッケージ由来の警告で `*Warnings*` や `*Compile-Log*` が勝手に開くのを避ける意図がある。

```elisp
(add-to-list 'display-buffer-alist
             '("\\`\\*Warnings\\*\\'" . (display-buffer-no-window)))
(add-to-list 'display-buffer-alist
             '("\\`\\*Compile-Log\\*\\'" . (display-buffer-no-window)))
```

`*Warnings*` と `*Compile-Log*` バッファを表示対象から外す。バッファ自体は存在しても、ウィンドウを奪わない。

## 3. XDG ディレクトリと設定用定数

```elisp
(defconst seli/opaque-ui-background "#2a273f")
(defconst seli/opaque-ui-background-active "#393552")
(defconst seli/buffer-alpha-background 88)
```

透過させない UI 部品用の背景色と、バッファ背景の透過率。`opaque-ui-*` はメニューバー、tab-line、モードラインなどをテーマ色で塗るために使う。`seli/buffer-alpha-background` は GUI フレーム背景の透過率で、`88` は少し透ける程度。

```elisp
(defconst seli/cache-dir
  (expand-file-name "emacs/" (or (getenv "XDG_CACHE_HOME") "~/.cache/")))
```

Emacs 用キャッシュ置き場。`XDG_CACHE_HOME` があればそこを使い、なければ `~/.cache/emacs/` を使う。

```elisp
(defconst seli/state-dir
  (expand-file-name "emacs/" (or (getenv "XDG_STATE_HOME") "~/.local/state/")))

(defconst seli/data-dir
  (expand-file-name "emacs/" (or (getenv "XDG_DATA_HOME") "~/.local/share/")))
```

`state-dir` は履歴や custom 設定などの状態ファイル用。`data-dir` は ELPA パッケージなど、再利用されるデータ用。

```elisp
(defconst seli/config-dir
  (file-name-directory (or load-file-name buffer-file-name)))
```

現在の `init.el` が置かれているディレクトリを取得する。後で `themes/` をテーマロードパスに追加するために使う。

```elisp
(dolist (dir (list seli/cache-dir seli/state-dir seli/data-dir))
  (unless (file-directory-p dir)
    (make-directory dir t)))
```

必要なディレクトリがなければ作る。`t` は親ディレクトリもまとめて作成する指定。

## 4. パッケージ管理と use-package

```elisp
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))
```

パッケージ取得元として GNU ELPA、NonGNU ELPA、MELPA を使う。MELPA があるので、最新寄りの外部パッケージも入れられる。

```elisp
(setq package-user-dir (expand-file-name "elpa" seli/data-dir))
(package-initialize)
```

パッケージのインストール先を `seli/data-dir/elpa` にする。通常の `~/.emacs.d/elpa` ではなく XDG 配下に置く設計。

```elisp
(unless package-archive-contents
  (package-refresh-contents))
```

パッケージ一覧が未取得なら更新する。初回起動時にはネットワークアクセスが発生する。

```elisp
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
```

`use-package` がなければインストールする。これ以降のパッケージ設定はほぼ `use-package` で書かれている。

```elisp
(setq use-package-always-ensure t
      use-package-always-defer t
      use-package-expand-minimally t)
```

`use-package-always-ensure t` により、明示的に `:ensure nil` しない限りパッケージを自動インストール対象にする。`use-package-always-defer t` は遅延ロードを基本にする設定。`use-package-expand-minimally t` は展開されるコードを少なめにし、起動時の負荷を抑える。

## 5. Evil の事前設定とカーソル形状

```elisp
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
```

Evil は読み込み前に設定しておくべき変数がある。ここでは Vim 風操作の細部を決めている。

- `evil-want-keybinding nil`: `evil-collection` を使うため、Evil 本体側の一部キーバインド統合を無効化。
- `evil-want-C-u-scroll t`: Vim と同じように `C-u` を上スクロールにする。
- `evil-want-C-i-jump nil`: `C-i` のジャンプ動作を無効化し、Tab との衝突を避ける。
- `evil-respect-visual-line-mode t`: 表示行単位の移動を尊重する。org buffer は `visual-line-mode` なので、折り返し行を 1 行として扱わない。
- 各 `evil-*-cursor`: normal は箱、insert は縦棒、operator は横棒など、状態ごとにカーソル形状を変える。

```elisp
(defconst seli/terminal-cursor-shapes
  '((box . "\e[2 q")
    (bar . "\e[6 q")
    (hbar . "\e[4 q")))
```

ターミナル Emacs でカーソル形状を変えるための DECSCUSR エスケープシーケンス。GUI だけでなく TUI でも Evil の状態が見た目で分かる。

```elisp
(defun seli/set-cursor-shape (shape)
  (setq-default cursor-type shape)
  (setq cursor-type shape)
  (unless (display-graphic-p)
    (let ((sequence (alist-get shape seli/terminal-cursor-shapes)))
      (when sequence
        (send-string-to-terminal sequence)))))
```

GUI では `cursor-type` を設定し、ターミナルでは対応するエスケープシーケンスを送る。`setq-default` と `setq` の両方を使い、既定値と現在バッファの両方に反映している。

```elisp
(defun seli/apply-evil-cursor-shape ()
  (seli/set-cursor-shape
   (pcase (and (boundp 'evil-state) evil-state)
     ('insert 'bar)
     ('replace 'bar)
     ('operator 'hbar)
     (_ 'box))))
```

現在の Evil state を見てカーソル形状を適用する。insert/replace は縦棒、operator は横棒、それ以外は箱にする。

## 6. ファイル、バックアップ、状態ファイル

```elisp
(setq backup-directory-alist `(("." . ,(expand-file-name "backup/" seli/cache-dir)))
      auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-save/" seli/cache-dir) t))
      auto-save-list-file-prefix (expand-file-name "auto-save-list/.saves-" seli/cache-dir)
      create-lockfiles nil
      custom-file (expand-file-name "custom.el" seli/state-dir)
      recentf-save-file (expand-file-name "recentf" seli/state-dir)
      savehist-file (expand-file-name "savehist" seli/state-dir)
      bookmark-default-file (expand-file-name "bookmarks" seli/state-dir))
```

Emacs が作る副産物を XDG 配下にまとめる設定。

- `backup-directory-alist`: `file~` のようなバックアップを作業ディレクトリではなく cache に置く。
- `auto-save-file-name-transforms`: `#file#` のような自動保存ファイルも cache に置く。
- `create-lockfiles nil`: `.#+file` のようなロックファイルを作らない。
- `custom-file`: Customize UI が書き込む設定を `init.el` から分離する。
- `recentf-save-file`, `savehist-file`, `bookmark-default-file`: 最近使ったファイル、ミニバッファ履歴、ブックマークを state に置く。

```elisp
(dolist (dir (list (expand-file-name "backup/" seli/cache-dir)
                  (expand-file-name "auto-save/" seli/cache-dir)
                  (expand-file-name "auto-save-list/" seli/cache-dir)))
  (unless (file-directory-p dir)
    (make-directory dir t)))
```

バックアップと自動保存の置き場を、初回起動時に作っておく。

## 7. エディタ基本動作

```elisp
(setq inhibit-startup-screen t
      ring-bell-function #'ignore
      visible-bell nil
      use-short-answers t
      confirm-kill-processes nil
      sentence-end-double-space nil
      require-final-newline t)
```

起動画面を消し、ベルを無効化し、`yes-or-no-p` 系の回答を短くし、終了時のプロセス確認を抑えている。`sentence-end-double-space nil` は、英文で文末をピリオド + スペース 1 個と判定する設定。

```elisp
(setq scroll-margin 3
      scroll-conservatively 101
      scroll-preserve-screen-position t
      scroll-step 1
      auto-window-vscroll nil
      fast-but-imprecise-scrolling t
      next-screen-context-lines 3)
```

スクロールの挙動を滑らかにし、カーソル周辺に余白を残す設定。`scroll-conservatively 101` は大きく画面を飛ばさず、必要最小限のスクロールに寄せる。

```elisp
(setq tab-width 2
      standard-indent 2
      fill-column 100
      indent-tabs-mode nil)

(setq-default tab-width 2
              indent-tabs-mode nil
              truncate-lines nil)
```

インデント幅を 2、タブ文字を使わない、折り返しあり、折り返し目安は 100 桁。`setq` は現在値、`setq-default` は今後開くバッファの既定値に効く。

```elisp
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
```

文字コードを UTF-8 優先にする。

```elisp
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
```

よく使う標準機能をまとめて有効化している。

- 相対行番号を表示 (org buffer では後述の hook で無効化)。
- 現在行をハイライト。
- モードラインに桁番号を表示。
- 対応する括弧を表示。
- ファイルが外部で変わったら自動再読み込み。
- 選択範囲がある状態で入力したら置換。
- ミニバッファ履歴と最近使ったファイルを保存。
- ウィンドウ構成の undo/redo を有効化。

```elisp
(defun seli/save-all-buffers ()
  "Save modified file buffers without prompting."
  (save-some-buffers t))

(add-hook 'focus-out-hook #'seli/save-all-buffers)
```

Emacs からフォーカスが外れた時に、変更済みファイルバッファを確認なしで保存する。書きかけの org ファイルを保存し忘れないための設定。

```elisp
(defface seli-dangerous-char
  '((t (:background "red" :foreground "white" :weight bold)))
  "Face for invisible or bidi control characters.")

(font-lock-add-keywords
 nil
 '(("[\u200B\u200C\u200D\uFEFF\u202E\u2066-\u2069]" 0 'seli-dangerous-char prepend)))
```

ゼロ幅文字や bidi 制御文字を赤背景で目立たせる。コピー & ペーストで紛れ込んだ見えない文字を発見しやすくする。

## 8. UI、透過、フォント、テーマ

```elisp
(defconst seli/transparent-background-faces
  '(default fringe line-number line-number-current-line ...))
```

背景を下地側に任せたい face の一覧。通常の背景、fringe、行番号、`hl-line` など、主にバッファ本文側の face を対象にしている。GUI ではこれらを `unspecified` にしたうえで `alpha-background` を使い、UI 部品は別途不透明色で塗る。

```elisp
(defconst seli/opaque-ui-faces
  '((menu . seli/opaque-ui-background-active)
    (tab-bar . seli/opaque-ui-background-active)
    (tab-line . seli/opaque-ui-background)
    (header-line . seli/opaque-ui-background)
    (mode-line . seli/opaque-ui-background-active)
    ...))
```

GUI Emacs で透けてほしくない UI 部品の face 一覧。メニューバーやモードラインなどは、透明背景を継承させず、テーマの濃い背景色を明示的に設定する。`tab-line` 系も含めることで、バッファタブとして表示される行を不透明にする。

```elisp
(defun seli/apply-frame-appearance (&optional frame)
  (let ((frame (or frame (selected-frame))))
    (dolist (face seli/transparent-background-faces)
      (when (facep face)
        (set-face-attribute face frame :background 'unspecified)
        (set-face-attribute face t :background 'unspecified)))
    (if (display-graphic-p frame)
        (progn
          (set-frame-parameter frame 'alpha '(100 . 100))
          (set-frame-parameter frame 'alpha-background seli/buffer-alpha-background)
          ...)
      (modify-frame-parameters frame '((background-color . "unspecified-bg"))))))
```

GUI フレームでは `alpha` を active/inactive とも `100` に固定し、ウィンドウ全体の opacity 変化を避ける。そのうえで `alpha-background` を `seli/buffer-alpha-background` にして、背景だけを透かす。メニューバー、tab-line、モードラインは `seli/opaque-ui-faces` のテーマ色で塗る。ターミナルでは背景色を `unspecified-bg` にする。

```elisp
(add-to-list 'default-frame-alist '(alpha . (100 . 100)))
(add-to-list 'default-frame-alist `(alpha-background . ,seli/buffer-alpha-background))
(add-hook 'after-make-frame-functions #'seli/apply-frame-appearance)
(advice-add 'load-theme :after #'seli/reapply-frame-appearance)
(seli/apply-frame-appearance)
```

起動直後、追加フレーム作成時、テーマロード後のすべてで外観設定を再適用する。テーマを読み込むと face の背景が上書きされるため、`load-theme` 後に再実行している。

```elisp
(defconst seli/default-font-family "Monaspace Radon Var")
(defconst seli/default-font-height 130)
(defconst seli/cjk-font-family "Yomogi")
```

GUI Emacs の既定フォントと日本語など CJK 用フォールバックフォント。`130` は 13pt 相当の高さ。日本語で org を書く前提なので、CJK フォールバックは重要。

```elisp
(add-to-list 'default-frame-alist '(font . "Monaspace Radon Var-13"))

(defun seli/apply-fonts (&optional frame)
  (let ((frame (or frame (selected-frame))))
    (when (display-graphic-p frame)
      (with-selected-frame frame
        (set-face-attribute 'default frame :family seli/default-font-family :height seli/default-font-height)
        (dolist (charset '(kana han cjk-misc))
          (set-fontset-font t charset (font-spec :family seli/cjk-font-family) frame))))))

(add-hook 'after-make-frame-functions #'seli/apply-fonts)
```

`default-frame-alist` で最初の GUI フレームから Radon を選び、さらに新しい GUI フレームごとに face と CJK フォールバックを設定する。これにより、daemon 起動時には GUI が存在しない場合でも `emacsclient` で開くフレームに設定が適用される。

```elisp
(setq tab-bar-show nil
      tab-line-close-button-show nil
      tab-line-new-button-show nil
      tab-line-separator "")

(menu-bar-mode -1)
(tool-bar-mode -1)
(tab-bar-mode -1)
(global-tab-line-mode -1)
```

メニューバー、ツールバー、`tab-bar`、バッファタブの `tab-line` を無効化して、GUI Emacs の上部 UI を表示しない。バッファの切り替えは `C-x b`（consult）で行う。

```elisp
(add-to-list 'custom-theme-load-path (expand-file-name "themes/" seli/config-dir))
(load-theme 'rose-pine-moon t)
```

`.config/emacs/themes/` をテーマ探索パスに追加し、ローカルテーマ `rose-pine-moon` を読み込む。このテーマは org と org-modern の face も定義している。

```elisp
(defun seli/toggle-theme ()
  (interactive)
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'rose-pine-moon t))
```

現在有効なテーマをすべて無効化してから `rose-pine-moon` を再読み込みする。名前は toggle だが、実際にはテーマの再適用関数。

### UI 系パッケージ

```elisp
(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 22)
  (doom-modeline-buffer-file-name-style 'auto)
  (doom-modeline-icon t))
```

モードラインを `doom-modeline` に置き換える。ファイル名表示は `auto` で、アイコンを有効化する。

```elisp
(use-package which-key
  :ensure nil
  :hook (after-init . which-key-mode)
  :custom
  (which-key-idle-delay 0.4))
```

キー入力の続きをポップアップ表示する Emacs 標準系の補助機能。`SPC` leader の候補表示に効く。

## 9. Evil と leader key

```elisp
(use-package evil-numbers
  :after evil
  :demand t)
```

カーソル位置の数値を増減するパッケージ。`C-a` / `C-x` に割り当てる。

```elisp
(use-package evil
  :demand t
  :config
  (evil-mode 1)
  ...)
```

Evil 本体を即時ロードして有効化する。`use-package-always-defer t` が全体設定されているが、`:demand t` によりここでは遅延させない。

```elisp
(dolist (hook '(evil-normal-state-entry-hook ...))
  (add-hook hook #'seli/apply-evil-cursor-shape))
```

Evil の state が変わるたびにカーソル形状を更新する。

```elisp
(define-key evil-normal-state-map (kbd "U") #'evil-redo)
(define-key evil-normal-state-map (kbd "C-b") nil)
(define-key evil-normal-state-map (kbd "C-a") #'evil-numbers/inc-at-pt)
(define-key evil-normal-state-map (kbd "C-x") #'evil-numbers/dec-at-pt)
```

normal state のキーを調整している。

- `U`: redo。
- `C-b`: 既定割り当てを解除。
- `C-a`: カーソル位置の数値を +1。
- `C-x`: カーソル位置の数値を -1。

```elisp
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))
```

Dired、Help、Org など Emacs 標準・外部パッケージの各モードに Evil 風キーバインドを入れる。

```elisp
(use-package general
  :demand t
  :after evil
  :config
  (general-create-definer seli/leader
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC"
    :non-normal-prefix "C-SPC"))
```

`general.el` で leader key 定義用の `seli/leader` を作る。normal/visual/motion state では `SPC`、それ以外では `C-SPC` を leader として使う。

```elisp
(seli/leader
  "SPC" '(execute-extended-command :which-key "M-x")
  "f" '(seli/consult-fd-buffer-tab :which-key "find files")
  "/" '(consult-ripgrep :which-key "grep")
  "s" '(consult-imenu :which-key "outline")
  "S" '(consult-org-heading :which-key "org headings")
  "o" '(:ignore t :which-key "org")
  "ot" '(org-todo :which-key "todo state")
  ...)
```

検索・移動と org 操作を `SPC` に集約している。`o` は org 用のサブプレフィックスで、`which-key` に "org" として表示される。

```elisp
(global-set-key (kbd "C-s") #'save-buffer)
```

Emacs 標準では `C-s` は検索だが、この設定では保存に割り当てる。なお `C-c` はグローバルに再割り当てしていないため、`C-c C-c` などの org 標準キーがそのまま使える。

## 10. 補完、検索、ナビゲーション

```elisp
(use-package vertico
  :hook (after-init . vertico-mode))
```

ミニバッファ補完 UI。`M-x`、ファイル選択、バッファ選択などの候補表示が縦型になる。

```elisp
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))
```

補完候補の絞り込みをスペース区切りの順不同マッチにする。ファイル補完だけは `basic` と `partial-completion` を使い、パス補完の自然さを残している。

```elisp
(use-package marginalia
  :hook (after-init . marginalia-mode))
```

ミニバッファ候補に注釈を追加する。コマンドなら説明、ファイルなら属性などが表示される。

```elisp
(use-package consult
  :bind (("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop))
  :custom
  (consult-fd-args "fd --color=never --hidden --exclude .git")
  (consult-ripgrep-args "rg --null --line-buffered ... --hidden --glob !.git"))
```

検索・移動系の強化パッケージ。`C-x b` は高機能バッファ切り替え、`M-y` は kill ring 履歴選択になる。`fd` と `rg` は hidden file も対象にするが、`.git` は除外する。

```elisp
(defun seli/consult-fd-buffer-tab ()
  "Find files with `consult-fd'."
  (interactive)
  (call-interactively #'consult-fd))
```

`consult-fd` で選んだファイルを通常のバッファとして開く関数。

```elisp
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
```

バッファ内補完 UI。2 文字入力後、0.15 秒で自動補完を出す。候補リストは循環可能で、Return で候補を確定する。org でもリンクや見出し語の入力補助として効く。

```elisp
(use-package cape
  :after corfu
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))
```

Corfu が使う補完ソースを追加する。ファイル名補完と dabbrev 補完を `completion-at-point-functions` に足している。

## 11. Org mode

```elisp
(defun seli/org-mode-defaults ()
  "Prose-friendly defaults for `org-mode' buffers."
  (display-line-numbers-mode 0)
  (setq-local truncate-lines nil))
```

org buffer では行番号を消し、長い行を折り返す。文章を書く用途では行番号よりも本文の幅を優先する。

```elisp
(use-package org
  :ensure nil
  :mode ("\\.org\\'" . org-mode)
  :hook ((org-mode . visual-line-mode)
         (org-mode . seli/org-mode-defaults))
  :custom
  (org-directory "~/org")
  (org-startup-indented t)
  (org-startup-folded 'content)
  (org-startup-with-inline-images t)
  (org-image-actual-width '(600))
  (org-pretty-entities t)
  (org-hide-emphasis-markers t)
  (org-ellipsis " ▾")
  (org-fontify-quote-and-verse-blocks t)
  (org-return-follows-link t)
  (org-insert-heading-respect-content t)
  (org-catch-invisible-edits 'show-and-error)
  (org-auto-align-tags nil)
  (org-tags-column 0))
```

org は Emacs 標準添付なので `:ensure nil`。各設定の意味は次のとおり。

- `org-directory`: org ファイルの既定の置き場。`~/org`。
- `org-startup-indented`: `org-indent-mode` を有効にし、本文を見出しのレベルに合わせて字下げ表示する。実ファイルにはスペースを入れない。
- `org-startup-folded 'content`: 開いた直後は見出しだけを見せる。全体像を掴んでから本文に入る運用。
- `org-startup-with-inline-images` と `org-image-actual-width`: 画像リンクをインライン表示し、幅を 600px に揃える。
- `org-pretty-entities`: `\alpha` などの LaTeX エンティティを実際の文字で表示する。
- `org-hide-emphasis-markers`: `*bold*` や `/italic/` の記号を隠し、装飾結果だけを見せる。
- `org-ellipsis`: 折りたたまれた見出しの末尾記号を `▾` にする。
- `org-fontify-quote-and-verse-blocks`: quote / verse ブロックに専用 face を当てる。
- `org-return-follows-link`: リンク上で Return を押すとリンクを開く。
- `org-insert-heading-respect-content`: `M-RET` での見出し追加を、本文の途中ではなく現在のセクションの末尾に行う。
- `org-catch-invisible-edits 'show-and-error`: 折りたたまれて見えない部分をうっかり編集しそうになったら、展開してエラーにする。
- `org-auto-align-tags nil` と `org-tags-column 0`: タグを右端揃えにせず見出し直後に置く。`org-modern` の表示と相性が良い。

```elisp
(use-package org-tempo
  :ensure nil
  :after org
  :demand t)
```

org 添付のテンプレート展開機能。行頭で `<q` と入力して `TAB` を押すと quote ブロックに展開される。`<e` は example、`<v` は verse。

```elisp
(use-package evil-org
  :after (evil org)
  :hook (org-mode . evil-org-mode)
  :config
  (evil-org-set-key-theme '(navigation insert textobjects additional calendar)))
```

org buffer に Evil 風の操作を足す。`navigation` は見出し間移動、`textobjects` は見出しや要素を対象にしたテキストオブジェクト、`additional` は `M-h` / `M-l` によるレベル変更や `M-j` / `M-k` による見出し移動、`calendar` は日付入力時の Vim 風カーソル移動。

```elisp
(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :custom
  (org-modern-star 'replace)
  (org-modern-hide-stars nil)
  (org-modern-table t)
  (org-modern-list '((?+ . "◦") (?- . "–") (?* . "•"))))
```

org の見た目を整えるパッケージ。`org-modern-star 'replace` で見出しの `*` を記号に置き換え、TODO やタグはラベル風に、表は罫線を整えて表示する。リストの記号も箇条書き用の文字に置き換える。

## 12. Dired

```elisp
(use-package dired
  :ensure nil
  :custom
  (dired-listing-switches "-alh --group-directories-first")
  :config
  (with-eval-after-load 'evil
    (evil-define-key 'normal dired-mode-map
      (kbd "RET") #'dired-find-file
      (kbd "l") #'dired-find-file
      (kbd "h") #'dired-up-directory
      (kbd "q") #'quit-window)))
```

Dired の一覧を詳細表示、サイズ human readable、ディレクトリ優先にする。Evil normal state では `l` / Enter で開き、`h` で上のディレクトリ、`q` で閉じる。org ファイルを置いたディレクトリを行き来する用途に使う。

## 13. 最後の custom-file 読み込み

```elisp
(when (file-exists-p custom-file)
  (load custom-file nil t))
```

Customize UI などが書いた `custom.el` が存在すれば読み込む。`nil t` により、メッセージを抑えつつエラーには寛容に読み込む。

## 14. 主なキーバインド一覧

| キー | 意味 |
| --- | --- |
| `C-s` | 現在バッファを保存 |
| `C-x b` | バッファ切り替え (consult) |
| `M-y` | kill ring 履歴 |
| normal `U` | redo |
| normal `C-a` | 数値 +1 |
| normal `C-x` | 数値 -1 |
| `SPC SPC` | `M-x` |
| `SPC f` | `fd` でファイル検索して開く |
| `SPC /` | `ripgrep` 検索 |
| `SPC n` | マッチしない行を隠す |
| `SPC m` | mark 一覧 |
| `SPC u` | undo / redo |
| `SPC s` | buffer 内の見出し / imenu |
| `SPC S` | org 見出し検索 |
| `SPC tb` | `rose-pine-moon` テーマ再読み込み |
| `SPC o t` | TODO 状態の切り替え |
| `SPC o c` | チェックボックスの切り替え |
| `SPC o l` | リンク挿入 |
| `SPC o o` | リンクを開く |
| `SPC o i` | インライン画像の表示切り替え |
| org `TAB` | 見出しの開閉 |
| org `M-RET` | 見出し / リスト項目の追加 |
| org `M-h` / `M-l` | 見出しレベルの上げ下げ (evil-org) |
| org `M-j` / `M-k` | 見出しの移動 (evil-org) |

## 15. 外部コマンド依存

この `init.el` が前提にしている外部コマンドは 2 つだけ。

| 用途 | コマンド |
| --- | --- |
| ファイル検索 | `fd` |
| grep | `rg` |

言語サーバーやフォーマッタへの依存はない。

## 16. 設定全体の設計意図

この設定の中心は次の 4 点。

1. `~/.emacs.d` を前提にせず、cache/state/data を XDG 配下に分ける。
2. Evil と leader key で Vim 風の高速操作に寄せる。
3. Vertico / Orderless / Marginalia / Consult / Corfu で、ミニバッファ補完とバッファ内補完を軽量に整える。
4. org mode に用途を絞り、org / evil-org / org-modern と自作テーマの org face だけで、書くことに集中できる状態にする。プログラミング向けの機能 (LSP、診断、フォーマッタ、デバッガ、言語 major mode、Git クライアント、端末) は意図的に持たない。
