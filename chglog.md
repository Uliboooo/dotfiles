# chglog

設定変更の記録の索引。実体は [chglog/](chglog/) 以下にトピック別で置いてある。

「なぜそうしたか」と「試して駄目だったこと」を残すのが目的で、何を変えたかだけなら
`git log` で足りる。書き方は [AGENT.md](AGENT.md) を参照。

## 索引

- [chglog/immich.md](chglog/immich.md) — desktop の写真・動画ライブラリ。sda の
  HDD にメディア、sdb の SSD に PostgreSQL を配置し、Tailscale 内だけで公開する。
- [chglog/power.md](chglog/power.md) — lid / suspend / hibernate / hypridle。
  S3 が無い機なので蓋起因の hibernate は amdgpu と競合して不可
- [chglog/login.md](chglog/login.md) — GDM / PAM / gnome-keyring。
  greetd + ReGreet は 2026-08-04 に撤回して GDM に戻した(GNOME の設定アプリが
  開かなくなるため)。キーリング解錠が SSH に効く
- [chglog/wayland.md](chglog/wayland.md) — クリップボードと D&D。
  端末アプリからブラウザへの D&D は原理的に不可、クリップボード経由で渡す
- [chglog/ssh.md](chglog/ssh.md) — SSH 越しの接続性。
  解錠済み gcr-ssh-agent の再利用、OSC52 クリップボード、kitty graphics / sixel
- [chglog/status-bar.md](chglog/status-bar.md) — Noctalia / Waybar の起動と切替。
- [chglog/niri.md](chglog/niri.md) — niri 固有の外部ツールと連携設定。
- [chglog/emacs.md](chglog/emacs.md) — Emacs daemon / GUI frame / posframe 固有の注意点。
- [chglog/systemd.md](chglog/systemd.md) — Home Manager で管理するユーザー単位の
  service / timer と、定期処理固有の注意点。

## 使い方

- 読むとき … この索引で当たりを付けて 1 ファイルだけ開く。当てが外れたら
  `grep -rn '<keyword>' chglog/` で横断する
- 書くとき … 該当トピックのファイルの先頭側に追記する。日付見出し
  `## YYYY-MM-DD` の下に `### <一行要約>`、新しいものを上
- トピックが無い変更 … 新しく `chglog/<topic>.md` を作り、この索引に 1 行足す。
  1 ファイルが読み通せなくなったら(目安 300 行)さらに割る。**日付では割らない**
