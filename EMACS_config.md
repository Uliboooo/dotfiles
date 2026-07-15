# Emacs init.el 解説

対象ファイル: `.config/emacs/init.el`

この設定は、Emacs を Vim 風の操作体系に寄せつつ、補完、検索、LSP、整形、Git、端末をまとめて使える開発環境として構成している。状態ファイルやキャッシュは XDG ディレクトリに逃がし、設定ディレクトリを汚しにくくしている。

## 1. ファイル先頭と基本ロード設定

```elisp
;;; init.el --- Seli Emacs config -*- lexical-binding: t; -*-
```

`lexical-binding: t` は Emacs Lisp の変数スコープを lexical scope にする指定。関数内で作ったローカル変数がクロージャとして安全に扱いやすくなり、現代的な Emacs Lisp ではほぼ標準の書き方。

```elisp
(require 'package)
(require 'seq)
```

`package` は Emacs 標準のパッケージ管理機能。`seq` は `seq-find` などのシーケンス操作関数を使うために読み込んでいる。後半の診断コピー関数で `seq-find` が使われる。

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

`state-dir` は履歴や custom 設定などの状態ファイル用。`data-dir` は ELPA パッケージや tree-sitter grammar など、再利用されるデータ用。

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
- `evil-respect-visual-line-mode t`: 表示行単位の移動を尊重する。
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
(setq treesit-extra-load-path (list (expand-file-name "tree-sitter/" seli/data-dir)))
```

tree-sitter grammar の探索パスを XDG data 配下にする。

```elisp
(when (boundp 'treesit--install-language-grammar-out-dir)
  (setq treesit--install-language-grammar-out-dir
        (expand-file-name "tree-sitter/" seli/data-dir)))
```

Emacs のバージョンによって存在する内部変数がある場合だけ、grammar のインストール先も同じ場所に合わせる。`boundp` により、未定義変数でエラーになるのを避けている。

## 7. エディタ基本動作

```elisp
(setq inhibit-startup-screen t
      ring-bell-function #'ignore
      visible-bell nil
      use-short-answers t
      confirm-kill-processes nil
      read-process-output-max (* 1024 1024)
      sentence-end-double-space nil
      require-final-newline t)
```

起動画面を消し、ベルを無効化し、`yes-or-no-p` 系の回答を短くし、終了時のプロセス確認を抑えている。`read-process-output-max` は LSP など外部プロセスとの通信を大きめに読み取るための調整。

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

- 相対行番号を表示。
- 現在行をハイライト。
- モードラインに桁番号を表示。
- 対応する括弧を表示。
- ファイルが外部で変わったら自動再読み込み。
- 選択範囲がある状態で入力したら置換。
- ミニバッファ履歴と最近使ったファイルを保存。
- ウィンドウ構成の undo/redo を有効化。

```elisp
(defun seli/prog-mode-defaults ()
  (setq-local indent-tabs-mode nil)
  (display-fill-column-indicator-mode 0))

(add-hook 'prog-mode-hook #'seli/prog-mode-defaults)
```

プログラミング系モードでタブインデントを無効にし、fill column indicator を消す。全体では `fill-column 100` を設定しているが、縦線表示は使わない方針。

```elisp
(defun seli/save-all-buffers ()
  "Save modified file buffers without prompting."
  (save-some-buffers t))

(add-hook 'focus-out-hook #'seli/save-all-buffers)
```

Emacs からフォーカスが外れた時に、変更済みファイルバッファを確認なしで保存する。外部ツールやビルドツールとの連携を重視した設定。

```elisp
(defface seli-dangerous-char
  '((t (:background "red" :foreground "white" :weight bold)))
  "Face for invisible or bidi control characters.")

(font-lock-add-keywords
 nil
 '(("[\u200B\u200C\u200D\uFEFF\u202E\u2066-\u2069]" 0 'seli-dangerous-char prepend)))
```

ゼロ幅文字や bidi 制御文字を赤背景で目立たせる。見えない文字や方向制御文字による混乱、いわゆる Trojan Source 系の問題を発見しやすくする。

## 8. UI、透過、フォント、テーマ

```elisp
(defconst seli/transparent-background-faces
  '(default fringe line-number line-number-current-line ...))
```

背景を下地側に任せたい face の一覧。通常の背景、fringe、行番号、`hl-line` など、主にバッファ本文側の face を対象にしている。GUI ではこれらを `unspecified` にしたうえで `alpha-background` を使い、UI 部品は別途不透明色で塗る。

```elisp
(defconst seli/opaque-ui-faces
  '((menu . seli/opaque-ui-background-active)
    (tool-bar . seli/opaque-ui-background-active)
    (tab-bar . seli/opaque-ui-background-active)
    (tab-bar-tab . seli/opaque-ui-background)
    (tab-bar-tab-inactive . seli/opaque-ui-background-active)
    (tab-bar-tab-group-current . seli/opaque-ui-background)
    (tab-bar-tab-group-inactive . seli/opaque-ui-background-active)
    (tab-bar-tab-ungrouped . seli/opaque-ui-background-active)
    (tab-line . seli/opaque-ui-background)
    (tab-line-tab . seli/opaque-ui-background-active)
    (tab-line-tab-current . seli/opaque-ui-background-active)
    (tab-line-tab-inactive . seli/opaque-ui-background)
    (tab-line-highlight . seli/opaque-ui-background-active)
    (tab-line-close-highlight . seli/opaque-ui-background-active)
    (header-line . seli/opaque-ui-background)
    (header-line-highlight . seli/opaque-ui-background-active)
    (mode-line . seli/opaque-ui-background-active)
    (mode-line-active . seli/opaque-ui-background-active)
    (mode-line-inactive . seli/opaque-ui-background)
    (mode-line-highlight . seli/opaque-ui-background-active)))
```

GUI Emacs で透けてほしくない UI 部品の face 一覧。メニューバーやモードラインなどは、透明背景を継承させず、テーマの濃い背景色を明示的に設定する。`tab-line` 系も含めることで、ファイル/バッファタブとして表示される行を不透明にする。

```elisp
(defun seli/apply-frame-appearance (&optional frame)
  (let ((frame (or frame (selected-frame))))
    (dolist (face seli/transparent-background-faces)
      (when (facep face)
        (set-face-attribute face frame :background 'unspecified)
        (set-face-attribute face t :background 'unspecified)))
    (when (display-graphic-p frame)
      (dolist (entry seli/opaque-ui-faces)
        ...))
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

GUI Emacs の既定フォントと日本語など CJK 用フォールバックフォント。`130` は 13pt 相当の高さ。

```elisp
(defun seli/apply-fonts ()
  (when (display-graphic-p)
    (when (member seli/default-font-family (font-family-list))
      (set-face-attribute 'default nil :family seli/default-font-family :height seli/default-font-height))
    (when (member seli/cjk-font-family (font-family-list))
      (dolist (charset '(kana han cjk-misc))
        (set-fontset-font t charset (font-spec :family seli/cjk-font-family))))))
```

フォントがインストールされている場合だけ適用する。存在確認をしているため、別環境でも起動エラーになりにくい。

```elisp
(setq tab-bar-show nil
      tab-line-close-button-show nil
      tab-line-new-button-show nil
      tab-line-separator "")

(tab-bar-mode -1)
(global-tab-line-mode 1)
```

Emacs 標準の `tab-bar` は無効化し、バッファをタブとして表示する `tab-line-mode` を全体で有効化する。閉じるボタン、新規ボタン、区切り文字は非表示にして、上部 UI をすっきりさせている。

```elisp
(add-to-list 'custom-theme-load-path (expand-file-name "themes/" seli/config-dir))
(load-theme 'rose-pine-moon t)
```

`.config/emacs/themes/` をテーマ探索パスに追加し、ローカルテーマ `rose-pine-moon` を読み込む。

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
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-icon t))
```

モードラインを `doom-modeline` に置き換える。ファイル名はプロジェクト相対で表示し、アイコンを有効化する。

```elisp
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))
```

括弧のネストを色分けする。

```elisp
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode))
```

`TODO` や `FIXME` などのコメントを目立たせる。

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

カーソル位置の数値を増減するパッケージ。後述の `C-a` / `C-x` に組み込まれている。

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
(define-key evil-normal-state-map (kbd "C-a") #'seli/increment-or-toggle-at-point)
(define-key evil-normal-state-map (kbd "C-x") #'seli/decrement-or-toggle-at-point)
(define-key evil-normal-state-map (kbd "K") #'eldoc-doc-buffer)
(define-key evil-normal-state-map (kbd "gd") #'xref-find-definitions)
(define-key evil-normal-state-map (kbd "gr") #'xref-find-references)
```

normal state のキーを調整している。

- `U`: redo。
- `C-b`: 既定割り当てを解除。
- `C-a`: 数値増加、または `true` / `false` トグル。
- `C-x`: 数値減少、または `true` / `false` トグル。
- `K`: Eldoc のドキュメントバッファを開く。
- `gd`: 定義ジャンプ。
- `gr`: 参照検索。

```elisp
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))
```

Dired、Magit、Help など Emacs 標準・外部パッケージの各モードに Evil 風キーバインドを入れる。

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
  "a" '(eglot-code-actions :which-key "code action")
  "r" '(eglot-rename :which-key "rename")
  "f" '(seli/consult-fd-buffer-tab :which-key "find files")
  "/" '(consult-ripgrep :which-key "grep")
  "l" '(magit-status :which-key "magit")
  "\\" '(seli/toggle-terminal :which-key "terminal")
  "dr" '(dape-repl :which-key "debug repl"))
```

主要機能を `SPC` から呼べるようにしている。検索、LSP アクション、診断、Git、端末、デバッグが leader に集約されている。

```elisp
(global-set-key (kbd "C-s") #'save-buffer)
(global-set-key (kbd "C-\\") #'seli/toggle-terminal)
```

Emacs 標準では `C-s` は検索だが、この設定では保存に割り当てる。端末トグルはグローバルに `C-\`。

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
  (consult-fd-args "fd --color=never --hidden --exclude .git ...")
  (consult-ripgrep-args "rg --null --line-buffered ... --hidden --glob !.git ..."))
```

検索・移動系の強化パッケージ。`C-x b` は高機能バッファ切り替え、`M-y` は kill ring 履歴選択になる。`fd` と `rg` は hidden file も対象にするが、`.git`、`node_modules`、`target`、`.mooncakes` は除外している。

```elisp
(defun seli/consult-fd-buffer-tab ()
  "Find files with `consult-fd', showing opened buffers in `tab-line-mode'."
  (interactive)
  (call-interactively #'consult-fd))
```

`consult-fd` で選んだファイルを通常のバッファとして開く関数。`global-tab-line-mode` が有効なので、開いたファイルは tab-line 上のバッファタブとして表示される。

```elisp
(use-package consult-eglot
  :after (consult eglot))
```

Eglot の workspace symbol 検索を Consult UI で使うための連携。

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

バッファ内補完 UI。2 文字入力後、0.15 秒で自動補完を出す。候補リストは循環可能で、Return で候補を確定する。

```elisp
(use-package cape
  :after corfu
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))
```

Corfu が使う補完ソースを追加する。ファイル名補完と dabbrev 補完を `completion-at-point-functions` に足している。

```elisp
(use-package yasnippet
  :hook (after-init . yas-global-mode))

(use-package yasnippet-snippets
  :after yasnippet)
```

スニペット展開を全体で有効化し、汎用スニペット集も導入する。

## 11. 編集支援とフォーマッタ

```elisp
(use-package smartparens
  :hook (prog-mode . smartparens-mode)
  :config
  (require 'smartparens-config))
```

括弧やクォートのペア入力、構造編集を支援する。プログラミング系モードで有効。

```elisp
(use-package apheleia
  :hook (after-init . apheleia-global-mode)
  :config
  ...)
```

保存時などに外部フォーマッタを実行する整形パッケージ。

```elisp
(setf (alist-get 'stylua apheleia-formatters)
      '("stylua" "--column-width" "100" "--indent-type" "Spaces" "--indent-width" "2"
        "--quote-style" "AutoPreferDouble" "--collapse-simple-statement" "Always" "-"))
```

Lua formatter の `stylua` を細かく指定している。100 桁、スペース 2、引用符は自動だが double quote 寄り、単純文は畳む。

```elisp
(setf (alist-get 'rustic-mode apheleia-mode-alist) 'rustfmt)
(setf (alist-get 'go-mode apheleia-mode-alist) 'gofmt)
(setf (alist-get 'typescript-ts-mode apheleia-mode-alist) 'biome)
(setf (alist-get 'nix-mode apheleia-mode-alist) 'nixfmt)
(setf (alist-get 'sh-mode apheleia-mode-alist) 'shfmt)
```

各 major mode と formatter の対応を指定している。Rust、Go、Lua、JSON、TypeScript、TSX、JavaScript、Nix、TOML、Shell、C/C++ が対象。

```elisp
(defun seli/toggle-comment ()
  (interactive)
  (if (use-region-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-line 1)))

(global-set-key (kbd "C-c") #'seli/toggle-comment)
```

選択範囲があれば範囲コメント、なければ現在行をコメントトグルする。`C-c` は Emacs では通常 prefix key なので、この設定ではかなり強く上書きしている。

### true/false トグルと数値増減

```elisp
(defun seli/boolean-at-point ()
  (let* ((bounds (bounds-of-thing-at-point 'symbol))
         (word (and bounds (buffer-substring-no-properties (car bounds) (cdr bounds)))))
    (cond
     ((string= word "true") (list bounds "false"))
     ((string= word "false") (list bounds "true"))
     (t nil))))
```

カーソル位置の symbol が `true` なら `false`、`false` なら `true` にするため、対象範囲と置換文字列を返す。

```elisp
(defun seli/toggle-boolean-at-point ()
  (when-let* ((pair (seli/boolean-at-point))
              (bounds (car pair))
              (replacement (cadr pair)))
    (delete-region (car bounds) (cdr bounds))
    (insert replacement)
    t))
```

実際に `true` / `false` を置換する。変更できた時は `t` を返す。

```elisp
(defun seli/increment-or-toggle-at-point ()
  (interactive)
  (unless (seli/toggle-boolean-at-point)
    (evil-numbers/inc-at-pt 1)))
```

カーソル位置が boolean ならトグルし、そうでなければ数値を 1 増やす。`decrement` 版は同じ考えで数値を 1 減らす。

## 12. LSP、診断、言語モード

```elisp
(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-no-changes-timeout 0.8)
  (flymake-show-diagnostics-at-end-of-line nil))
```

Emacs 標準の診断 UI。プログラミング系モードで有効化し、変更後 0.8 秒で診断を走らせる。行末への診断表示は無効。

```elisp
(use-package eglot
  :ensure nil
  :init
  (dolist (hook '(rust-mode-hook rust-ts-mode-hook ...))
    (add-hook hook #'eglot-ensure))
  ...)
```

Emacs 標準 LSP クライアント Eglot。Rust、Go、C/C++、Python、JavaScript/TypeScript、CSS、HTML、Lua、Zig、Markdown、Nix、Typst、Astro などで自動起動する。

```elisp
(setq eglot-autoshutdown t
      eglot-events-buffer-size 0
      eglot-ignored-server-capabilities '(:documentHighlightProvider))
```

Eglot の挙動調整。

- `eglot-autoshutdown t`: 管理対象バッファがなくなったら LSP サーバーを終了。
- `eglot-events-buffer-size 0`: Eglot イベントログを保持しない。
- `:documentHighlightProvider` を無視: カーソル位置のシンボルハイライトを LSP 側から受け取らない。

```elisp
(add-to-list 'eglot-server-programs
             '((rust-mode rust-ts-mode)
               . ("rust-analyzer" :initializationOptions
                  (:cargo (:allFeatures t)
                   :check (:command "clippy")
                   :inlayHints ...))))
```

Rust は `rust-analyzer` を使い、全 features 有効、check は `clippy`、inlay hints を有効化している。

```elisp
(add-to-list 'eglot-server-programs
             '((js-mode js-ts-mode typescript-ts-mode tsx-ts-mode)
               . ("typescript-language-server" "--stdio")))
```

JavaScript / TypeScript / TSX は `typescript-language-server`。

```elisp
(add-to-list 'eglot-server-programs
             '((c-mode c-ts-mode c++-mode c++-ts-mode) . ("clangd")))
(add-to-list 'eglot-server-programs
             '((go-mode go-ts-mode) . ("gopls")))
(add-to-list 'eglot-server-programs
             '(zig-mode . ("zls")))
(add-to-list 'eglot-server-programs
             '(lua-mode . ("lua-language-server")))
(add-to-list 'eglot-server-programs
             '((python-mode python-ts-mode) . ("basedpyright-langserver" "--stdio")))
(add-to-list 'eglot-server-programs
             '(nix-mode . ("nil")))
(add-to-list 'eglot-server-programs
             '(typst-ts-mode . ("tinymist")))
(add-to-list 'eglot-server-programs
             '(web-mode . ("astro-ls" "--stdio")))
(add-to-list 'eglot-server-programs
             '(markdown-mode . ("marksman")))
```

各言語の LSP サーバー対応。外部コマンドが PATH にある前提で動作する。

```elisp
(add-hook 'eglot-managed-mode-hook #'eglot-inlay-hints-mode)
```

Eglot 管理下のバッファで inlay hints を有効にする。

### 診断コピー関数

```elisp
(defun seli/copy-current-diagnostic ()
  "Copy first Flymake diagnostic on the current line with source context."
  ...)
```

現在行にある Flymake 診断を探し、前後 3 行のソース文脈つきで kill ring にコピーする関数。leader key の `SPC dc` に割り当てられている。

```elisp
(seq-find
 (lambda (d)
   (and (<= (flymake-diagnostic-beg d) line-end)
        (>= (flymake-diagnostic-end d) line-start)))
 (flymake-diagnostics line-start line-end))
```

現在行の範囲と重なる診断を 1 つ探す。

```elisp
(kill-new text)
(message "Diagnostic copied to clipboard.")
```

診断種別、診断本文、行番号、周辺コードをまとめてコピーする。AI や issue に貼る用途に向いた関数。

### 言語 major mode

```elisp
(use-package markdown-mode)
(use-package nix-mode)
(use-package lua-mode)
(use-package go-mode)
(use-package rust-mode)
(use-package zig-mode)
(use-package json-mode)
```

各言語の major mode を導入する。

```elisp
(use-package toml-ts-mode
  :ensure nil
  :mode "\\.toml\\'")
```

Emacs 標準の tree-sitter TOML mode を `.toml` に関連付ける。

```elisp
(use-package typst-ts-mode
  :mode "\\.typ\\'")
(use-package web-mode
  :mode "\\.astro\\'")
```

Typst と Astro 用の mode 関連付け。

### Dired

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

Dired の一覧を詳細表示、サイズ human readable、ディレクトリ優先にする。Evil normal state では `l` / Enter で開き、`h` で上のディレクトリ、`q` で閉じる。

```elisp
(add-to-list 'auto-mode-alist '("\\.mbt\\'" . prog-mode))
```

`.mbt` ファイルを最低限 `prog-mode` として扱う。専用 major mode は使っていない。

## 13. Git

```elisp
(use-package magit
  :commands (magit-status magit-blame-addition))
```

Git UI として Magit を導入する。`magit-status` などのコマンドが呼ばれた時にロードする。

```elisp
(use-package diff-hl
  :hook ((prog-mode text-mode conf-mode) . diff-hl-mode)
  :config
  (diff-hl-flydiff-mode 1))
```

Git の変更行を fringe などに表示する。`flydiff` により編集中の差分表示も更新される。

## 14. 端末とデバッグ

```elisp
(use-package eat
  :commands (eat eat-make)
  :config
  (define-key eat-mode-map (kbd "C-\\") #'seli/toggle-terminal)
  ...)
```

Emacs 内ターミナルとして `eat` を使う。`eat-mode`、`eat-semi-char-mode`、`eat-char-mode` の各 keymap で `C-\` を端末トグルに割り当てる。

```elisp
(defvar seli/terminal-buffer-name "*terminal*")
(defconst seli/terminal-window-height 0.3)
```

専用端末バッファ名と、下部サイドウィンドウの高さ。`0.3` はフレーム高さの 30%。

```elisp
(defun seli/project-root-or-default-directory ()
  (let ((project (project-current nil)))
    (if project (project-root project) default-directory)))
```

現在位置がプロジェクト内ならプロジェクトルートを返し、そうでなければ現在ディレクトリを返す。端末起動時の作業ディレクトリに使う。

```elisp
(defun seli/get-or-create-terminal-buffer ()
  (let* ((default-directory (seli/project-root-or-default-directory))
         (buffer (get-buffer seli/terminal-buffer-name))
         (process (and buffer (get-buffer-process buffer))))
    (if (and process (process-live-p process))
        buffer
      (eat-make "terminal" (or explicit-shell-file-name shell-file-name)))))
```

既存の `*terminal*` バッファに生きているプロセスがあれば再利用し、なければ `eat-make` で新しい端末を作る。`default-directory` を let で束縛しているため、端末はプロジェクトルートから起動する。

```elisp
(defun seli/toggle-terminal ()
  (interactive)
  (let* ((buf (seli/get-or-create-terminal-buffer))
         (win (get-buffer-window buf t)))
    (if (and buf (get-buffer-window buf))
        (delete-window win)
      (select-window
       (display-buffer-in-side-window
        buf
        `((side . bottom)
          (slot . 0)
          (window-height . ,seli/terminal-window-height)
          (preserve-size . (nil . t))
          (dedicated . t)))))))
```

専用端末を下部サイドウィンドウとして表示・非表示する。表示済みなら閉じ、未表示なら高さ 30% の dedicated window として開く。

```elisp
(use-package dape
  :commands (dape dape-breakpoint-toggle dape-repl)
  :config
  (setq dape-buffer-window-arrangement 'right))
```

Debug Adapter Protocol クライアント `dape` を導入する。デバッグ関連バッファは右側配置にする。

## 15. 最後の custom-file 読み込み

```elisp
(when (file-exists-p custom-file)
  (load custom-file nil t))
```

Customize UI などが書いた `custom.el` が存在すれば読み込む。`nil t` により、メッセージを抑えつつエラーには寛容に読み込む。

## 16. 主なキーバインド一覧

| キー | 意味 |
| --- | --- |
| `C-s` | 現在バッファを保存 |
| `C-\` | 専用端末を表示・非表示 |
| `C-c` | 行または選択範囲のコメントトグル |
| normal `U` | redo |
| normal `C-a` | `true` / `false` トグル、または数値 +1 |
| normal `C-x` | `true` / `false` トグル、または数値 -1 |
| normal `K` | Eldoc ドキュメント表示 |
| normal `gd` | 定義へ移動 |
| normal `gr` | 参照を検索 |
| `SPC SPC` | `M-x` |
| `SPC a` | LSP code action |
| `SPC r` | LSP rename |
| `SPC f` | `fd` でファイル検索し、tab-line のバッファタブとして開く |
| `SPC /` | `ripgrep` 検索 |
| `SPC m` | mark 一覧 |
| `SPC dd` | Flymake 診断一覧 |
| `SPC dc` | 現在行の診断を周辺コードつきでコピー |
| `SPC s` | buffer 内 symbol 検索 |
| `SPC S` | workspace symbol 検索 |
| `SPC l` | Magit status |
| `SPC \` | 専用端末を表示・非表示 |
| `SPC tb` | `rose-pine-moon` テーマ再読み込み |
| `SPC b` | Dape breakpoint toggle |
| `SPC dr` | Dape REPL |

## 17. 外部コマンド依存

この `init.el` は Emacs パッケージだけでなく、いくつかの外部コマンドが PATH にある前提で動く。

| 用途 | コマンド |
| --- | --- |
| ファイル検索 | `fd` |
| grep | `rg` |
| Rust LSP | `rust-analyzer` |
| Rust check | `clippy` |
| TypeScript LSP | `typescript-language-server` |
| C/C++ LSP | `clangd` |
| Go LSP / formatter | `gopls`, `gofmt` |
| Zig LSP | `zls` |
| Lua LSP / formatter | `lua-language-server`, `stylua` |
| Python LSP | `basedpyright-langserver` |
| Nix LSP / formatter | `nil`, `nixfmt` |
| Typst LSP | `tinymist` |
| Astro LSP | `astro-ls` |
| Markdown LSP | `marksman` |
| Shell formatter | `shfmt` |
| C/C++ formatter | `clang-format` |
| JS/TS/JSON formatter | `biome` |
| TOML formatter | `taplo` |

## 18. 設定全体の設計意図

この設定の中心は次の 5 点。

1. `~/.emacs.d` を前提にせず、cache/state/data を XDG 配下に分ける。
2. Evil と leader key で Vim 風の高速操作に寄せる。
3. Vertico / Orderless / Marginalia / Consult / Corfu で、ミニバッファ補完とバッファ内補完を軽量に整える。
4. Eglot / Flymake / Apheleia で、LSP 診断と自動整形を標準機能寄りにまとめる。
5. Magit、diff-hl、eat、dape を入れて、Git、端末、デバッグまで Emacs 内で完結しやすくする。
