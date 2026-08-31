# GnuPG / pinentry

pinentry は GUI で表示する。Fish は Home Manager の `programs.fish` では管理して
いないため、シェル統合の一部を `.config/fish/config.fish` に手書きする。

## 2026-08-27

### pinentry-qt を gpg-agent に接続

触ったファイル: `home/common_user.nix`, `.config/fish/config.fish`

`services.gpg-agent.pinentry.package` に `pkgs.pinentry-qt` を指定する。パッケージを
インストールするだけでは agent の `pinentry-program` は選択されない。

Zsh は Home Manager の gpg-agent 統合を使う。Fish は `programs.fish` を有効にすると
既存の `config.fish` と所有権が衝突するため、interactive shell の開始時に
`GPG_TTY` を `tty` の値へ更新する。
