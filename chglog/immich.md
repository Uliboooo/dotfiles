# Immich

desktop (selipaq) で NixOS の `services.immich` を使う。メディアは `sda1` の ext4
HDD (`/run/media/seli/hdd`)、PostgreSQL は `sdb1` の ext4 SSD
(`/run/media/seli/ssd`) に置く。Immich は `tailscale0` の TCP 2283 だけで公開し、LAN と
インターネットからは公開しない。外部バックアップは未構成。

## 2026-08-13

### NixOS ネイティブの Immich を desktop に追加

対象: `hosts/desktop/configuration.nix`, `chglog.md`, `chglog/immich.md`

`services.immich` の組み込み PostgreSQL / Redis を使い、Immich の既定の UNIX socket
接続を維持したため、DB パスワード用の秘密ファイルは不要。`services.postgresql.dataDir`
を SSD 上に移し、両ディスクを待ってから Immich / PostgreSQL の所有者付きディレクトリを
作成する `immich-storage-prepare.service` を両サービスの必須依存として置いた。

`systemd-tmpfiles` はディスクのマウントが完了していない時点で実行され得る。初回の
`nixos-rebuild switch` では sdb の再マウント直後に PostgreSQL のデータディレクトリが
存在せず、`ReadWritePaths` の mount namespace 構築が `226/NAMESPACE` で失敗した。tmpfiles
ではなく、マウントを `RequiresMountsFor` で待つ oneshot で作成する。

実機確認では `sda1` は ext4 / UUID `8d675241-ce9e-4c58-b18b-fd2b686bd749`、`sdb1` は
ext4 / UUID `cd76b396-71ae-48a3-a3e3-b953bc460496`。従来の sdb の exFAT / UUID
`FE35-EF25` 定義は実機と不一致だったため修正した。

Immich は `0.0.0.0:2283` で listen するが、`openFirewall` は有効にせず、
`networking.firewall.interfaces.tailscale0.allowedTCPPorts` だけを開ける。接続先は
`http://<selipaq の Tailscale 名または IP>:2283`。
