# Neovim Configuration

モダンなLua設定による高機能Neovim環境。Rust/TypeScript/Go/Pythonなど多言語開発に最適化。

## プラグイン管理

- **[lazy.nvim](https://github.com/folke/lazy.nvim)**: プラグインマネージャー
  - 自動更新有効（起動時にバックグラウンドで更新チェック）
  - 遅延読み込み対応

## ビジュアル・UI

### カラースキーム

- **[rose-pine](https://github.com/rose-pine/neovim)**: メインカラースキーム
  - バリアント: `rose-pine-moon`
  - 透過背景有効
  - カスタムハイライト設定（Visual、Search、LspReferenceなど）

### ステータスライン・インジケーター

- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)**: ステータスライン
  - 表示内容: モード、ブランチ、diff、diagnostics、ファイルパス、LSPシンボル位置、ファイルサイズ、ファイルタイプ
  - nvim-navic統合でコード内位置を表示

- **[nvim-navic](https://github.com/SmiteshP/nvim-navic)**: LSPシンボル位置をステータスラインに表示
  - LSP対応ファイルで現在のクラス/関数などを表示

- **[nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)**: ファイルタイプアイコン

- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)**: Git統合
  - 行単位の変更マーカー（追加/変更/削除）
  - リアルタイムblame表示（右端に作者・日付・コミットメッセージ）
  - 更新間隔: 1000ms

- **[rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim)**: 括弧のレインボーカラー表示

- **[nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)**: 高度なコード折りたたみ
  - プロバイダー: treesitter + indent

## ✏️ 編集機能

### 補完・スニペット

- **[blink.cmp](https://github.com/saghen/blink.cmp)**: 高速補完エンジン
  - ソース: LSP、パス、スニペット、バッファ
  - nvim-cmp互換の見た目
  - Enter: 補完確定

- **[friendly-snippets](https://github.com/rafamadriz/friendly-snippets)**: スニペット集

### 自動入力支援

- **[nvim-autopairs](https://github.com/windwp/nvim-autopairs)**: 括弧の自動ペア入力

- **[nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag)**: HTMLタグの自動クローズ
  - Treesitter連携

- **[mini.comment](https://github.com/echasnovski/mini.comment)**: コメントトグル

### フォーマッター

- **[conform.nvim](https://github.com/stevearc/conform.nvim)**: コードフォーマッター
  - **保存時自動フォーマット有効**（タイムアウト: 500ms）
  - 対応フォーマッター:
    - **C/C++**: clang-format
    - **Rust**: rustfmt（LSPフォールバック）
    - **Go**: gofmt
    - **Lua**: stylua
    - **JSON/JSONC**: biome
    - **Shell**: shfmt

## 🔧 LSP・言語サポート

### LSP管理

- **[mason.nvim](https://github.com/williamboman/mason.nvim)**: LSPサーバー/DAP/リンターのパッケージマネージャー

- **[mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)**: LSP自動インストール
  - 自動インストール対象: `ts_ls`, `lua_ls`, `marksman`, `basedpyright`, `astro`

- **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)**: LSP設定

### 対応言語サーバー

| 言語 | LSP | 特記事項 |
|------|-----|----------|
| **Rust** | rust_analyzer | clippy有効、inlay hints全種有効（型、パラメータ、チェイン、ライフタイム、式調整、クロージャキャプチャ）、全機能有効 |
| **TypeScript/JavaScript** | ts_ls, biome | 2つのLSP併用 |
| **C/C++** | clangd | |
| **Go** | gopls | inlay hints有効（パラメータ名、変数型）、gofumpt、staticcheck有効 |
| **Python** | basedpyright | 型チェック: standard、診断モード: openFilesOnly |
| **HTML** | html, emmet_ls | Emmet展開サポート |
| **CSS/SCSS/LESS** | cssls, emmet_ls | |
| **Lua** | lua_ls | Neovim API対応、配列インデックスヒント無効 |
| **Markdown** | marksman | |
| **Astro** | astro | |
| **Zig** | zls | |
| **MoonBit** | moonbit-lsp | カスタム言語サーバー |

### LSP機能

- **診断表示**: virtual text無効、カーソルホールド時に自動的にfloat表示
- **Inlay Hints**: 対応言語で自動有効化
- **診断フロート**: 透過背景、ソース表示、rounded border
- **ホバードキュメント**: `K`キー
- **定義ジャンプ**: `gd`キー
- **参照検索**: `gr`キー（Snacks picker使用）
- **コードアクション**: `<Leader>a`
- **リネーム**: `<Leader>r`

### 言語固有プラグイン

- **[crates.nvim](https://github.com/saecki/crates.nvim)**: Rust Cargo.toml管理
  - クレートバージョン情報表示、更新チェック

## 🐛 デバッグ（DAP）

- **[nvim-dap](https://github.com/mfussenegger/nvim-dap)**: Debug Adapter Protocol
  - アダプター: codelldb（Rust/C/C++対応）

- **[nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)**: デバッグUI
  - デバッグセッション開始/終了時に自動開閉

- **[mason-nvim-dap.nvim](https://github.com/jay-babu/mason-nvim-dap.nvim)**: DAP自動インストール
  - 自動インストール対象: `codelldb`

## 🌲 構文解析

- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)**: シンタックスハイライト
  - 自動インストール: lua, vim, vimdoc, query, tsx, typescript
  - フォールディング用の式提供

- **[nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)**: テキストオブジェクト
  - `af`: 関数全体選択
  - `if`: 関数内部選択
  - `ac`: クラス全体選択
  - `ic`: クラス内部選択

## 🚀 ユーティリティ

- **[snacks.nvim](https://github.com/folke/snacks.nvim)**: 統合ユーティリティプラグイン
  - **ファイルピッカー**: fd使用、隠しファイル対応、除外: .git, node_modules, target, .mooncakes
  - **grep**: ripgrep使用、正規表現対応
  - **マーク管理**: マーク一覧
  - **Undo履歴**: undo tree
  - **診断一覧**: プロジェクト全体の診断
  - **LSPシンボル検索**: バッファ/ワークスペース
  - **lazygit統合**: Neovim内でlazygit起動
  - **インデントガイド**: インデント可視化
  - **通知システム**: 統合通知
  - **スムーススクロール**: スクロールアニメーション
  - **bigfile**: 大きいファイルの最適化

- **[toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)**: ターミナル
  - フローティングウィンドウ、curved border
  - サイズ: 画面サイズ - マージン

## ⚙️ エディタ設定

### 表示設定

```lua
vim.opt.relativenumber = true          -- 相対行番号
vim.opt.number = true                  -- 絶対行番号（カーソル行）
vim.opt.cursorline = true              -- カーソルライン表示
vim.opt.signcolumn = "yes"             -- サインカラム常時表示
vim.opt.termguicolors = true           -- 24bit色有効
```

### 不可視文字表示

```lua
vim.opt.list = true
vim.opt.listchars = {
  tab = "› ",      -- タブ
  trail = "~",     -- 行末スペース
  nbsp = "␣",      -- ノーブレークスペース
}
```

### 折り返し設定

```lua
vim.opt.wrap = true              -- 折り返し有効
vim.opt.linebreak = true         -- 単語境界で折り返し
vim.opt.breakindent = true       -- インデント保持
vim.opt.showbreak = "⤷ "         -- 折り返しマーカー
```

### インデント・タブ

```lua
vim.opt.tabstop = 2              -- タブ幅: 2
vim.opt.shiftwidth = 2           -- インデント幅: 2
vim.opt.expandtab = true         -- タブをスペースに展開
```

### その他

```lua
vim.opt.clipboard = "unnamedplus"  -- システムクリップボード連携
vim.opt.hlsearch = true            -- 検索ハイライト
vim.opt.updatetime = 1000          -- CursorHold待機時間: 1秒
vim.opt.mouse = "a"                -- マウス有効
vim.opt.autoread = true            -- 外部変更を自動読み込み
vim.opt.modeline = false           -- modeline無効（セキュリティ）
```

### フォールディング

```lua
vim.opt.foldmethod = "expr"                           -- 式フォールディング
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"  -- Treesitter使用
vim.opt.foldenable = true                             -- フォールディング有効
vim.opt.foldlevel = 99                                -- デフォルトレベル: 全展開
vim.opt.foldlevelstart = 99                           -- 起動時レベル: 全展開
vim.opt.foldcolumn = "auto"                           -- フォールドカラム自動
vim.opt.foldtext = ""                                 -- フォールドテキスト無効
```

### セキュリティ

- **危険な不可視文字の可視化**: Zero-width space、RLO、bidi文字などを赤背景で表示

### 自動コマンド

- **FocusGained/BufEnter**: 自動で外部変更をチェック（`:checktime`）
- **VimEnter**: ディレクトリを開いた場合はイントロ画面を表示、Enterでファイルピッカー起動

### ファイルタイプ

- `.mbt` → `moonbit`

## ⌨️ キーマッピング

### Leader キー

```lua
vim.g.mapleader = " "           -- Space
vim.g.maplocalleader = "\\"     -- Backslash
```

### 基本編集

| モード | キー | 機能 | 説明 |
|--------|------|------|------|
| n | `U` | Redo | Ctrl+rの代替 |
| n, i, v | `<C-s>` | 保存 | `:w` |
| v | `>` | インデント右 | 選択維持 |
| v | `<` | インデント左 | 選択維持 |
| n | `<C-b>` | 無効化 | - |

### コメント（mini.comment）

| モード | キー | 機能 | 説明 |
|--------|------|------|------|
| n | `<C-c>` | カレント行コメントトグル | - |
| x | `<C-c>` | 選択範囲コメントトグル | ビジュアルモード |

### LSP

| モード | キー | 機能 | 説明 |
|--------|------|------|------|
| n | `K` | ホバードキュメント | LSP hover |
| n | `gd` | 定義ジャンプ | LSP definition |
| n | `gr` | 参照検索 | Snacks picker |
| n | `<Leader>a` | コードアクション | LSP code action |
| n | `<Leader>r` | リネーム | LSP rename |
| n | `<Leader>s` | LSPシンボル | バッファ内シンボル検索 |
| n | `<Leader>ss` | LSPワークスペースシンボル | ワークスペース全体のシンボル検索 |
| n | `<Leader>d` | 診断一覧 | プロジェクト全体の診断 |
| n | `eh` | Inlay Hints有効化 | 現在バッファのみ |
| n | `dc` | 診断メッセージコピー | カーソル行の診断をクリップボードへ |

### ファイル・検索（Snacks）

| モード | キー | 機能 | 説明 |
|--------|------|------|------|
| n | `<Leader>f` | ファイル検索 | fd使用、隠しファイル対応 |
| n | `<Leader>/` | Grep検索 | ripgrep使用 |
| n | `<Leader>m` | マーク一覧 | - |
| n | `<Leader>u` | Undo履歴 | Undo tree |
| n | `<CR>` | ファイルピッカー | イントロ画面でのみ |

### Git（Gitsigns）

| モード | キー | 機能 | 説明 |
|--------|------|------|------|
| n | `<C-p>` | Hunkプレビュー | インラインで差分表示 |
| n | `<Leader>l` | lazygit起動 | Neovim内でlazygit |

### ターミナル（ToggleTerm）

| モード | キー | 機能 | 説明 |
|--------|------|------|------|
| n, t | `<C-\>` | ターミナルトグル | フローティングターミナル |

### デバッグ（DAP）

| モード | キー | 機能 | 説明 |
|--------|------|------|------|
| n | `<F5>` | Continue | デバッグ続行/開始 |
| n | `<F10>` | Step Over | ステップオーバー |
| n | `<F11>` | Step Into | ステップイン |
| n | `<F12>` | Step Out | ステップアウト |
| n | `<Leader>b` | ブレークポイント | トグル |
| n | `<Leader>dr` | REPL | デバッグREPL開く |

### 検索

| モード | キー | 機能 | 説明 |
|--------|------|------|------|
| n | `<Leader>n` | 検索ハイライト解除 | `:nohlsearch` |

## 📂 ディレクトリ構成

```
.config/nvim/
├── init.lua                    # エントリーポイント
├── lazy-lock.json              # プラグインバージョンロック
└── lua/
    ├── config/
    │   ├── config.lua          # エディタ設定
    │   ├── keymap.lua          # キーマッピング
    │   └── lazy.lua            # lazy.nvim設定
    └── plugins/
        ├── edit.lua            # 編集機能プラグイン
        ├── lldb.lua            # デバッグ設定
        ├── lsp.lua             # LSP設定
        ├── rust.lua            # Rust専用
        ├── snacks.lua          # Snacksユーティリティ
        ├── term.lua            # ターミナル
        ├── treesitter.lua      # Treesitter
        └── visual.lua          # UI/ビジュアル
```

## 🚀 使い方

### インストール

1. この設定を配置:
```bash
# dotfilesをクローン済みの場合
cd ~/dotfiles
# シンボリックリンク作成等はsetupスクリプトで対応
```

2. Neovim起動:
```bash
nvim
```

3. 初回起動時に自動で:
   - lazy.nvimのインストール
   - プラグインのインストール
   - LSPサーバー/DAPの自動インストール（mason経由）

### よく使う操作

#### ファイル操作
1. `<Space>f` でファイル検索
2. `<Space>/` でgrep検索
3. `<C-s>` で保存

#### コーディング
1. `K` でドキュメント表示
2. `gd` で定義ジャンプ
3. `gr` で参照検索
4. `<Space>a` でコードアクション
5. `<C-c>` でコメントトグル
6. 保存時に自動フォーマット

#### Git操作
1. `<Space>l` でlazygit起動
2. `<C-p>` で変更差分プレビュー
3. ステータスラインに自動でblame表示

#### デバッグ
1. `<Space>b` でブレークポイント設定
2. `F5` でデバッグ開始
3. `F10`/`F11`/`F12` でステップ実行

## 🔧 カスタマイズのヒント

### プラグインの追加

`lua/plugins/` ディレクトリに新しいファイルを作成:

```lua
-- lua/plugins/myplug.lua
return {
  {
    "user/plugin-name",
    config = function()
      -- 設定
    end,
  },
}
```

### LSPサーバーの追加

`lua/plugins/lsp.lua` の `vim.lsp.config()` セクションに追加:

```lua
vim.lsp.config("new_lsp", {
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "myfiletype" },
})
vim.lsp.enable("new_lsp")
```

### フォーマッターの追加

`lua/plugins/edit.lua` の `conform.nvim` 設定に追加:

```lua
formatters_by_ft = {
  myfiletype = { "myformatter" },
}
```

## 📝 備考

- **パフォーマンス**: bigfile検出、遅延読み込み、Treesitter最適化により高速動作
- **セキュリティ**: modeline無効、危険文字の可視化
- **透過背景**: ターミナルの背景透過が反映される設定
- **自動更新**: 起動時にプラグインを自動更新（バックグラウンド）
