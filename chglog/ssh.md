# chglog / SSH

SSH 越しの接続性と利便性 (クリップボード / 画像表示 / SSH エージェント)。

前提:

- クライアント端末は kitty 0.48 / ghostty 1.3 で、どちらも OSC52 と kitty
  graphics protocol (ghostty は sixel も) に対応している。
- `~/.config/tmux/clipboard.sh` は tmux の `copy-pipe-and-cancel` から呼ぶ。
  `~/.config/tmux/` は home-manager の `xdg.configFile` に登録していないため、
  リポジトリ直下のまま `$HOME/dotfiles/...` の絶対パスで参照している。

書き方は [../AGENT.md](../AGENT.md) を参照。

---

## 2026-08-06

### SSH セッションから gcr-ssh-agent の解錠済み鍵をそのまま使う (GitHub のパスフレーズ省略)

- `.config/fish/config.fish`
- `.zshrc`

`selinoir -ssh-> selipaq -ssh-> github` の形で、**selipaq 上で GitHub への SSH を
パスフレーズなしで通す**のが目的。PAM で SSH ログイン時にキーリングを解錠する
必要は無い。コンソール (GDM) ログインの時点で gnome-keyring が既に解錠されており、
gcr-ssh-agent が鍵を持った状態で常駐している。SSH セッションのシェルが
`SSH_AUTH_SOCK` を gcr のソケットに向けるだけで良い:

```fish
if test -z "$SSH_AUTH_SOCK"; and test -S "$XDG_RUNTIME_DIR/gcr/ssh"
    set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gcr/ssh"
end
```

検証 (実機):

- `SSH_AUTH_SOCK=/run/user/1000/gcr/ssh ssh-add -l` で 2 本の ED25519 鍵が
  解錠済みで並ぶ (`seli@selix` / `seli@selitank`)。
- `env -u SSH_AUTH_SOCK fish -c '...'` / `zsh -c '...'` で未設定時に
  `/run/user/1000/gcr/ssh` が入ることを確認。

ハマりどころ:

- **`SSH_AUTH_SOCK` が既に設定されているとき (例: `ssh -A` の agent forwarding)
  は上書きしない**。`-z "$SSH_AUTH_SOCK"` ガードを入れてある。
- **コンソールに一度もログインしていない起動 (ヘッドレス) では gcr の socket が
  無い**。その場合は何も起きず従来どおり `ssh github` はパスフレーズを聞かれる。
  この機 (GDM 付きデスクトップ) では実用上問題ないと判断。socket が無い状況まで
  カバーするなら boot 時に agent を立てる別方式が要る。
- `security.pam.services.*.enableGnomeKeyring` 等の追加は不要。SSH ログイン時の
  PAM はこの目的には一切関わらない。

### tmux / nvim のクリップボードを OSC52 でクライアント端末へ

- `.config/nvim/lua/config/config.lua`
- `.config/kitty/kitty.conf`
- `.tmux.conf`
- `.config/tmux/clipboard.sh` (新規)

SSH 先で `wl-copy` を叩いてもローカルのクリップボードには届かないので、OSC52 で
**クライアント端末** (kitty / ghostty) のクリップボードへ直接渡す。

- nvim: `SSH_CONNECTION` / `SSH_TTY` / `TMUX` のいずれかがあれば、組み込みの
  `vim.ui.clipboard.osc52` (nvim 0.12 で確認) を `vim.g.clipboard` に設定。
  ローカル (コンソール) では従来どおり wl-copy を使う。
- tmux: `set-clipboard on` のまま `terminal-features ',*:osc52'` を追加。
  **copy-pipe に渡したコマンドの stdout は tmux サーバ側で捨てられる**ので、
  ペインから自前で OSC52 を出しても届かない。tmux 自身の自動転送 (選択 →
  set-clipboard on → クライアントへ OSC52) に頼る設計。
  `clipboard.sh` はローカル (非 SSH) のときだけ wl-copy に流す。
- kitty: `clipboard_control` に `read-clipboard read-primary` を追加。無いと
  SSH 先の nvim で `"+p` を押したとき OSC52 の読み取り応答が来ず、nvim が
  "Waiting for OSC 52 response..." で 9 秒タイムアウトする。

ハマりどころ:

- **ghostty の OSC52 読み取りは既定でプロンプトが出る** (`clipboard-read` の
  既定値が `ask`)。書き込みは無条件で許可。読み取りも無条件にしたいなら
  `clipboard-read = allow` を ghostty の config に足す (今回は既定のまま)。
- **nvim の OSC52 ペーストは tmux を挟むと tmux 内部バッファが返る**。
  tmux は `set-clipboard on` で OSC52 クエリに自前のバッファで応答するため、
  クライアントの最新クリップボードとはズレうる。コピー (書き込み) は問題ない。

### 画像表示プロトコル (kitty graphics / sixel) を tmux 越しで通す

- `.tmux.conf`

- `terminal-features ',*:graphics'` … kitty graphics protocol をクライアントへ
  転送。yazi のプレビューや `chafa -f kitty` が tmux 越しで描画される。
  tmux 3.7b で有効 (`tmux -V` で確認)。tmux が画像を自前でグリッドに描くため、
  スクロールバックにも残る。
- `terminal-features ',*:sixel'` … kitty protocol に未対応のクライアント向けの
  フォールバック。
- `set -g default-terminal "tmux-256color"` … `screen-256color` から変更。
  tmux-256color の terminfo は `Ms` (OSC52) を持ち、内側の nvim から見ても
  クリップボード対応が検出できる。
- `allow-passthrough on` は既に有効でそのまま。

yazi は端末への動的クエリで protocol を判定するので、SSH 越しの裸の端末
(ghostty / kitty) では設定無しで画像プレビューが効く。tmux を挟むと上記の
`graphics` feature が要る。

ハマりどころ:

- **`terminal-features ',*:sixel'` を全クライアントに付けるのは、この機の
  kitty / ghostty 前提の割り切り**。sixel 未対応のクライアントを後で繋ぐ場合は
  対象を限定すること。
- クライアントが ghostty の場合、`~/.config/ghostty/config` の
  `term=xterm-256color` のままでも kitty graphics / sixel は動的クエリで効く
  (TERM 文字列には依存しない)。ghostty は両プロトコル対応。
