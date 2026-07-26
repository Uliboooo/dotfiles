# chglog / Wayland・クリップボード

クリップボード、D&D、端末アプリと GUI アプリの間のデータ受け渡し。

前提として、**端末アプリからブラウザへの D&D は原理的にできない**(Wayland の
drag source になれるのは GUI クライアントだけ)。代替はクリップボード経由。

書き方は [../AGENT.md](../AGENT.md) を参照。

---

## 2026-07-27

### yazi からブラウザへファイルを渡す (GUI クリップボード経由)

- `.config/yazi/scripts/gui-copy.sh` (新規)
- `.config/yazi/plugins/gui-copy.yazi/main.lua` (新規)
- `.config/yazi/keymap.toml`

端末アプリからブラウザへの D&D は原理的に無理(Wayland の drag source になれるのは
GUI クライアントだけ)なので、代わりに GUI クリップボードへ載せて貼り付けで渡す。
`<C-y>` = file:// URI 固定、`<A-y>` = 中身 or URI の自動判定。使用頻度が高いのは
アップロード領域へ渡す URI の方なので、押しやすい `<C-y>` をそちらに割り当てている。

型の選び方が肝で、ここを間違えるとブラウザが受け取らない:

- 画像は `wl-copy --type image/png` のように実 MIME で載せる。これで Chrome や
  Web アプリの Ctrl+V が File として拾う
- テキストは **`--type` を付けない**。付けると wl-copy が `text/plain` /
  `UTF8_STRING` / `STRING` の別名を提供しなくなり、貼り付け先が候補型を見つけられない。
  `xdg-mime` が `text/x-shellscript` などを返すので、そのまま渡すと余計に外す
- PDF や複数選択は中身を貼っても意味がないので `text/uri-list` (CRLF 区切り、
  RFC 2483)。Chromium 系のアップロード領域へ「ファイルとして」貼れる

ハマりどころ:

- **`shell -- ... %s` は選択が空のときコマンドごと実行されない**。`%h` を並べても
  同じで、ホバーしているだけでは発火しない。実測(`script -qec` の pty 上で
  `%h` / `%s` / `%h %s` をプローブ)で確認したので、選択→ホバーのフォールバックは
  Lua 側 (`cx.active.selected` → `cx.active.current.hovered`) で解決している
- **`xdg-mime` は `--` を受け付けない** (`unexpected option '--'`)。この機には
  `file` コマンドが入っていないので MIME 判定は `xdg-mime query filetype` 一択
- **wl-copy の fork した子が stdout を握ったままになる**。プラグインは
  `Command:output()` で待つので、`wl-copy ... >/dev/null 2>&1` にしておかないと
  クリップボードが次に上書きされるまで EOF が来ず yazi が固まる
- **`setsid wl-copy` にしないと貼り付けられない**。最初これを忘れて「cliphist には
  画像が入っているのに貼れない」状態になった。Wayland のクリップボードは
  wl-copy が居座ってデータを提供し続ける方式なので、こいつが死ぬと offer だけ残った
  抜け殻になる(cliphist は生きている間に読み終えているので残る)。実測でも
  `wl-paste --list-types` は `image/png` を返すのに `pgrep wl-copy` は空だった。
  yazi の子プロセスグループ / 端末に紐付いたままだと後始末や SIGHUP で道連れになる。
  `setsid` を挟めば yazi 終了後も生き残り、`wl-paste --type image/png` で中身が取れる
  ことを確認済み
- URI は python3 の `urllib.parse.quote` で percent-encode する。日本語名や空白の
  ファイルで parse に失敗させないため
- pty 越しの自動テストは、yazi 起動時の DA1 問い合わせが入力を食う
  (`Terminal failed to respond to DA1 ...: [14]` = 送った `\x0e` が応答として消費
  された)。`\x19` (`<C-y>`) も同様に届かないので、キーバインドの実発火はこの方法では
  確かめられない。ロジックはスクリプト直叩きと実クリップボード
  (`wl-paste --list-types`) で確認済み
