# Emacs Quick Start

このメモは、この dotfiles の Emacs 設定に合わせた最小限の使い方です。
前提は `Evil + leader key` です。Neovim から移るなら、まずここだけ覚えれば十分です。

## 起動

- GUI: `emacs`
- TUI: `emacs -nw`

この設定は `~/.config/emacs` を直接書き換えません。実体はこの repo の [`.config/emacs/init.el`](/home/seli/dotfiles/.config/emacs/init.el) です。

## 画面の見方

- 左端の行番号は相対行番号です
- 変更行は `diff-hl` で表示されます
- 右上のモード表示は `doom-modeline` です
- `which-key` により `SPC` の候補が少し待つと出ます

## 基本の考え方

- `Evil` が入っているので、通常は Normal mode で操作します
- `SPC` は leader key です
- `C-s` は保存です
- `C-\` はターミナル切り替えです
- `C-c` はコメント切り替えです

## 最初に覚えるキー

- `SPC f`: ファイル検索 (`fd`)
- `SPC /`: grep 検索
- `SPC SPC`: コマンド実行
- `SPC l`: Magit
- `SPC tb`: light/dark テーマ切り替え
- `SPC d d`: 現在行の diagnostics
- `SPC d c`: 現在行の diagnostic をコピー
- `SPC a`: code action
- `SPC r`: rename
- `SPC \\`: terminal
- `gd`: 定義へ移動
- `gr`: 参照へ移動
- `K`: hover

## 編集の基本

- `i`: insert mode に入る
- `Esc`: Normal mode に戻る
- `U`: redo
- `C-a`: 数値を増やす、`true/false` も切り替える
- `C-x`: 数値を減らす、`true/false` も切り替える
- `>` / `<`: インデント
- `C-c`: 1 行または選択範囲をコメント化/解除

## 検索と移動

この設定では `consult` を使います。

- `SPC f`: `fd` ベースのファイル検索
- `SPC /`: `rg` ベースの全文検索
- `SPC s`: 現在バッファのシンボル一覧
- `SPC S`: workspace シンボル一覧
- `SPC m`: マーク一覧
- `SPC u`: undo 履歴

補足:

- `C-x b` は buffer 切り替えです
- `M-y` は yank 履歴です

## Git

- `SPC l`: Magit を開く
- `diff-hl` が差分を左端に表示します
- 行単位で blame を見たいときは Magit 側の blame 機能を使います

## Filer

ディレクトリを開くと基本は `Dired` です。

- `j` / `k`: 移動
- `RET` または `l`: ファイルを開く
- `h` または `^`: 親ディレクトリへ戻る
- `q`: filer を閉じる

## LSP

LSP は `eglot` です。

- Rust: `rust-analyzer`
- Go: `gopls`
- C/C++: `clangd`
- TypeScript/JavaScript: `typescript-language-server`
- Python: `basedpyright`
- Lua: `lua-language-server`
- Nix: `nil`
- Markdown: `marksman`
- Typst: `tinymist`
- Astro: `web-mode` + `astro-ls`

動作は次のとおりです。

- ファイルを開くと自動で LSP が付く
- `K` で hover
- `gd` で定義
- `gr` で参照
- `SPC a` で code action
- `SPC r` で rename

## Format on Save

保存時に formatter が走ります。

- Rust: `rustfmt`
- Go: `gofmt`
- Lua: `stylua`
- JSON / JSONC / JS / TS: `biome`
- shell: `shfmt`
- Nix: `nixfmt`
- TOML: `taplo`
- C/C++: `clang-format`

## Terminal

- `SPC \\` または `C-\\` で terminal を切り替えます
- `eat` を使うので、Emacs 内で shell を開けます
- terminal を閉じるときも `SPC \\` または `C-\\` を使います
- terminal は下側の専用 window として開きます

## Debug

- `SPC b`: breakpoint の切り替え
- `SPC d r`: debug REPL

この設定では `dape` を使っています。

## Theme

- 起動時は `modus-vivendi` が基本です
- `SPC tb` で `modus-vivendi` と `modus-operandi` を切り替えます
- GUI では背景透過を有効にしています

## 文字化けや警告について

- 危険文字は赤背景で強調します
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
3. `gd` / `gr` で移動する
4. `SPC a` / `SPC r` で LSP 操作をする
5. `SPC l` で Git を見る
