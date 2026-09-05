# Neovim

Neovim の LSP 実行ファイルは、dev shell の `PATH`、Home Manager / NixOS の
`PATH`、Mason のユーザーデータディレクトリの順で探索する。

## 2026-09-04

### Python dev shell は basedpyright を Nix から供給する

触ったファイル: `.config/nvim/lua/plugins/lsp.lua`, `modules/common.nix`,
`flake_templates/python.nix`

Python 用 LSP 設定は `basedpyright` で、nvim-lspconfig の既定コマンド
`basedpyright-langserver --stdio` を `PATH` から探索する。Neovim 設定には Python 用の
formatter は無く、処理系も固定していない。通常環境では `modules/common.nix` の
`python3` (`/run/current-system/sw/bin/python`) が見える。

Mason も `basedpyright` を `ensure_installed` に含める。Mason の既定値 `PATH = "prepend"`
では dev shell より Mason が優先されるため、設定を `PATH = "append"` にして、dev shell
やシステムにコマンドが無い場合だけ `~/.local/share/nvim/mason/bin` にフォールバックする。
ただし 2026-09-04 の実機では、Mason が Python 3.13 で作った venv の `python3` が更新後の
システム Python 3.14 を指しており、`basedpyright-langserver --version` が
`ModuleNotFoundError: No module named 'basedpyright'` で失敗した。

`flake_templates/python.nix` は `python3`、`basedpyright`、Python の lint / format 用の
`ruff` を dev shell の `PATH` に置く。これによりプロジェクト内では Mason の venv に
依存せず、Nix 側の LSP と処理系を使える。
