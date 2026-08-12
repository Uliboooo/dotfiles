# Emacs Quick Start

このメモは、この dotfiles の Emacs 設定に合わせた最小限の使い方です。
前提は `Evil + leader key` です。この設定は **org mode 専用** で、LSP・フォーマッタ・デバッガ・Git クライアント・端末は入っていません。

## 起動

- GUI: `emacs`（Emacs daemon に新しいフレームを開く）
- GUI を明示: `emacsclient --create-frame`
- TUI: `emacsclient --tty`

Emacs daemon はグラフィカルセッションの開始時に systemd user service として起動する。
rofi の「Emacs」も同じ daemon に接続するため、起動済みのバッファや設定を共有する。
`Super+Backslash` / `Super+[` の scratchpad は独立した Emacs プロセスのため、通常の
Emacs とはバッファ・未保存の編集・履歴を共有しない。

この設定は `~/.config/emacs` を直接書き換えません。実体はこの repo の [`.config/emacs/init.el`](/home/seli/dotfiles/.config/emacs/init.el) です。

## 画面の見方

- 左端の行番号は相対行番号です (org buffer では非表示)
- 右下のモード表示は `doom-modeline` です
- `which-key` により `SPC` の候補が少し待つと出ます

## 基本の考え方

- `Evil` が入っているので、通常は Normal mode で操作します
- `SPC` は leader key です
- `C-s` は保存です
- `C-c` は org の prefix (`C-c C-c` など) です

## 最初に覚えるキー

- `SPC f`: ファイル検索 (`fd`)
- `SPC /`: grep 検索 (`rg`)
- `SPC SPC`: コマンド実行 (`M-x`)
- `SPC s`: 現在バッファの見出し一覧
- `SPC S`: org 見出し検索
- `SPC o t`: TODO 状態を切り替え
- `SPC tb`: テーマを読み込み直す

## 編集の基本

- `i`: insert mode に入る
- `Esc`: Normal mode に戻る
- `U`: redo
- `C-a`: 数値を増やす
- `C-x`: 数値を減らす
- `>` / `<`: インデント

## 検索と移動

この設定では `consult` を使います。

- `SPC f`: `fd` ベースのファイル検索
- `SPC /`: `rg` ベースの全文検索
- `SPC s`: 現在バッファの見出し / imenu
- `SPC S`: org 見出しへジャンプ
- `SPC m`: マーク一覧
- `SPC n`: マッチしない行を隠す
- `SPC u`: undo / redo

補足:

- `C-x b` は buffer 切り替えです
- `M-y` は yank 履歴です

## Org

`.org` を開くと org mode になります。既定の置き場は `~/org` (`org-directory`) です。

### 見た目

- `org-modern` で見出し・タグ・チェックボックス・表を装飾します
- 起動時は `org-startup-folded 'content` なので、見出しだけが開いた状態になります
- `org-startup-indented` により本文は見出しに合わせてインデント表示されます
- `*bold*` などの強調記号は隠します (`org-hide-emphasis-markers`)
- 画像リンクはインライン表示します (幅 600px)
- `visual-line-mode` で長い行は折り返します

### よく使うキー

- `TAB`: 見出しの開閉、`S-TAB`: 全体の開閉
- `M-RET`: 同じレベルの見出し / リスト項目を追加
- `M-h` / `M-l`: 見出しのレベルを上げ下げ (evil-org)
- `M-k` / `M-j`: 見出しを上下に移動 (evil-org)
- `SPC o t`: TODO / DONE を切り替え
- `SPC o c`: チェックボックスを切り替え
- `SPC o l`: リンクを挿入、`SPC o o`: リンクを開く
- `SPC o i`: インライン画像の表示切り替え
- `C-c C-c`: その場のもの (表・チェックボックス・タグ等) を更新
- `C-x g`: Magit の status を開く

### テンプレート (org-tempo)

行頭で `<` に続けて文字を入力し `TAB` を押すとブロックが展開されます。

- `<q` → quote ブロック
- `<e` → example ブロック
- `<v` → verse ブロック

## Filer

ディレクトリを開くと基本は `Dired` です。

- `j` / `k`: 移動
- `RET` または `l`: ファイルを開く
- `h` または `^`: 親ディレクトリへ戻る
- `q`: filer を閉じる

## 補完

- `corfu` によりバッファ内補完が自動で出ます (2 文字入力後)
- `RET` で確定します
- `cape` によりファイル名 (`cape-file`) とバッファ内単語 (`cape-dabbrev`) が候補に入ります

## Theme

- 起動時は同梱の `rose-pine-moon` を読み込みます (`.config/emacs/themes/`)
- `SPC tb` はテーマを読み込み直します (light/dark の切り替えではありません)
- GUI では背景透過を有効にしています

## 文字化けや警告について

- 危険文字 (ゼロ幅文字・bidi 制御文字) は赤背景で強調します
- `*Warnings*` と `*Compile-Log*` は通常は前面に出しません
- 初回起動時の package install は少し時間がかかります

## XDG の注意点

この設定は以下を dotfiles の外に出します。

- package データ: `~/.local/share/emacs`
- cache: `~/.cache/emacs`
- state: `~/.local/state/emacs`

つまり、Emacs の可変データは [`.config/emacs/init.el`](/home/seli/dotfiles/.config/emacs/init.el) とは別管理です。

## 迷ったら

1. `SPC f` でファイルを開く
2. `SPC /` で検索する
3. `SPC s` / `SPC S` で見出しへ飛ぶ
4. `TAB` で折りたたみを開閉する
5. `SPC SPC` でコマンドを探す
