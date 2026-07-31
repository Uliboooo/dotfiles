# chglog / ネットワーク・DNS

DNS の解決先、systemd-resolved、Tailscale (MagicDNS) の噛み合わせ。

前提として、**Tailscale を入れた時点で「resolv.conf を誰が持つか」の勝負になる**。
`networking.nameservers` に書いただけでは Tailscale 起動中は効かない(下記)。

書き方は [../AGENT.md](../AGENT.md) を参照。

---

## 2026-07-31

### Tailscale (MagicDNS) を残したまま通常の名前解決を 1.1.1.1 に固定する

- `hosts/desktop/configuration.nix:16-45`

結論。`networking.networkmanager.dns` を `"none"` から `"systemd-resolved"` にし、
`services.resolved.enable = true` を足した。これで `*.ts.net` だけ 100.100.100.100、
それ以外は 1.1.1.1 に分かれる。加えて `connectionConfig` で `ipv4/ipv6.ignore-auto-dns`
を既定 on にし、DHCP 由来の DNS が 1.1.1.1 を押しのけないようにしている。

**元の `dns = "none"` + `networking.nameservers = [ "1.1.1.1" ... ]` は、Tailscale が
上がっている間まったく効いていなかった。** tailscaled は起動時に resolv.conf の管理者を
判定し、resolved も resolvconf も居ない構成では "direct" と判断して
`/etc/resolv.conf` を自分で書き換える(退避は `/etc/resolv.pre-tailscale-backup.conf`)。
結果 `nameserver 100.100.100.100` 一行だけになり、非 MagicDNS のクエリは
100.100.100.100 → 管理コンソールの Global nameservers という経路で出ていく。
resolved が居ると tailscaled は D-Bus (`SetLinkDNS` / `SetLinkDomains`) を使い、
tailscale0 リンクにだけ 100.100.100.100 と `~<tailnet>.ts.net` を登録して、
グローバルな解決先には手を出さない。これが「両立」の実体。

nixpkgs 側で確認した事実 (nixos-unstable, 2026-07-31 時点):

- `services.resolved.settings.Resolve.DNS` の既定値が `config.networking.nameservers`
  (`nixos/modules/system/boot/resolved.nix:95-102`)。既存の 1.1.1.1 の記述はそのまま
  resolved の `DNS=` になるので、書き換えずに済む
- resolved 有効時は `/etc/resolv.conf` が `/run/systemd/resolve/stub-resolv.conf` への
  symlink になる(同 `:209-211`)。tailscaled の manager 判定もこの symlink 先を見る
- `networking.networkmanager.connectionConfig` は `[connection]` セクションに素通しで、
  型は `attrsOf (nullOr (oneOf [bool int str]))`
  (`nixos/modules/services/networking/networkmanager.nix:172-193`)。bool をそのまま書ける

**前提(壊すと全部無駄になる)**: 管理コンソールの DNS → **"Override local DNS" は
無効のまま**にすること。有効にすると tailscaled が tailscale0 に `~.`(デフォルト
ルート)を張り、結局すべてのクエリが MagicDNS 経由になる。

採らなかった案:

- **管理コンソールの Global nameservers に 1.1.1.1 を入れる**。いちばん手数が少なく、
  `dns = "none"` のままでも狙い通り 1.1.1.1 に流れる(direct manager が
  100.100.100.100 を挟み、そこから転送されるため)。tailnet 全体の設定なので他の
  デバイスにも一律で効く。端末単位で決めたかったので採用しなかっただけで、案として
  死んでいるわけではない
- **`--accept-dns=false`** (`services.tailscale.extraSetFlags` が
  `tailscaled-set` サービスとして `tailscale set` を流す:
  `nixos/modules/services/networking/tailscale.nix:128, 237-248`)。resolv.conf は
  1.1.1.1 のまま残るが MagicDNS 名 (`host.tailnet.ts.net`) が引けなくなる。
  100.x の IP 直打ちしか残らないので却下
- **NetworkManager の `[global-dns-domain-*] servers=...`**。per-connection 設定を
  上書きできるはずだが、`dns = "systemd-resolved"` バックエンドとの組み合わせの
  可否を裏取りできなかった(networkmanager.dev がこの環境のプロキシから 403)。
  挙動の確実な `ignore-auto-dns` を選んだ

ハマりどころ:

- DHCP の DNS を無視するので、**ルータが配るローカル名 (`foo.local` 等) は引けない**。
  ただしこれは `dns = "none"` 時代と同じ制約で、今回の変更で悪化はしていない
- resolved は「リンクに DNS が設定されていれば、グローバルの `DNS=` より
  そちらを使う」。`ignore-auto-dns` を外すと静かに DHCP の DNS に戻るので、
  1.1.1.1 に来ないときはまずここを疑う
- resolved の `FallbackDNS` は上流ビルドの既定値(Cloudflare / Google 等)のまま。
  `DNS=` が生きている限り使われないが、意図しない転送先を完全に消したいなら
  `services.resolved.settings.Resolve.FallbackDNS` を明示する

確かめられなかったこと:

- **実機で未検証**。この変更はリモートコンテナ上で書いており nix が入っていないため、
  `nixos-rebuild build --flake .#desktop` も `nix eval` も走らせていない。評価が通るかは
  CI (`nix-validate.yml`) 待ち。動作確認は実機で以下を見る
  - `resolvectl status` … Global の DNS Servers が `1.1.1.1 1.0.0.1`
  - `resolvectl status tailscale0` … DNS Servers が `100.100.100.100`、
    DNS Domain が `~<tailnet>.ts.net`(ここが `~.` なら Override local DNS が on)
  - `resolvectl query <host>.<tailnet>.ts.net` と `resolvectl query example.com` で
    使われたリンクが分かれること
