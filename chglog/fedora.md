# Fedora / standalone Home Manager

Fedora 側が OS、権限付き service、ログイン shell を管理し、flake の
`homeConfigurations.seli` は `seli` のユーザー環境だけを管理する。

## 2026-09-02

### Fedora の初回導入を 1 本のスクリプトにした

触ったファイル: `script/fedora-home-manager-bootstrap.sh`, `.config/fish/config.fish`,
`README.md`

`script/fedora-home-manager-bootstrap.sh` は Fedora / `seli` / x86_64 / `~/dotfiles` を
明示的に検査する。これらは現在の `flake.nix` と out-of-store symlink の
固定値であり、暗黙に別ユーザーへ適用すると誤った home を書き換える。

Fedora では SELinux を無効化せず、SELinux 対応を持つ Determinate Nix の
multi-user installer を使う。既存の Nix がある場合は再インストールしない。
初回 activation の衝突は UTC timestamp 付きの `-b` extension で退避し、
同名 backup が残って再実行に失敗するのを防ぐ。

fish は Fedora の `/usr/bin/fish` を login shell にする。`programs.fish` は
out-of-store の `.config/fish` と所有権が衝突するので有効化しない。
NixOS 外でもコマンドを見つけられるよう、`config.fish` が installer の
`nix-daemon.fish` を読み、`~/.nix-profile/bin` を PATH に追加する。
