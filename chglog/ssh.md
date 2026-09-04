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

## 2026-09-04

### 端末の light/dark ヒントを SSH 越しに引き継ぐ

- `home/seli.nix`
- `modules/common.nix`

Kitty は `TERM_BACKGROUND=light` を子プロセスへ設定するが、SSH が自動転送する端末用
変数は `TERM` だけなので、接続先では値が消えて Neovim と `fastfetch` が dark 側へ
フォールバックしていた。Home Manager の全ホスト向け SSH 設定で
`SendEnv TERM_BACKGROUND`、NixOS の sshd 設定で `AcceptEnv TERM_BACKGROUND` を指定する。

受信した変数はセッション環境へ export されるため、同じ設定を持つホスト間なら
`selinoir -> selipaq -> ...` のような多段 SSH でも次の接続へ引き継がれる。送信先が
`AcceptEnv` を設定していない場合は単に無視される。

ハマりどころ:

- `SendEnv` だけでは不十分で、接続先 sshd の `AcceptEnv` も必要。
- NixOS の型は `services.openssh.settings.AcceptEnv = [ "TERM_BACKGROUND" ];`、現行
  Home Manager の型は `programs.ssh.settings."*".SendEnv = [ "TERM_BACKGROUND" ];`。
- 反映には送信側の Home Manager 適用と受信側の NixOS `switch` が必要。既に接続中の
  セッションには遡及しないため、適用後に SSH 接続を張り直す。

検証:

- desktop / thinkpad / standalone Home Manager の `nix eval` が成功。
- `nixos-rebuild build --flake .#desktop` が成功し、生成物の `sshd_config` に
  `AcceptEnv TERM_BACKGROUND`、Home Manager の SSH config に
  `SendEnv TERM_BACKGROUND` が入ることを確認。

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
- tmux: `set-clipboard on` のまま `terminal-features ',*:clipboard'` を追加。
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

### Kitty graphics protocol を tmux 越しで通す

- `.tmux.conf`

- `allow-passthrough on` … tmux passthrough escape sequence を可視ペインから
  クライアント端末へ転送する。`kitten icat` は tmux を自動検出し、Unicode
  placeholder と passthrough を使う。chafa では必要なら
  `chafa -f kitty --passthrough tmux FILE` と明示できる。
- `set -g default-terminal "tmux-256color"` … `screen-256color` から変更。
  tmux-256color の terminfo は `Ms` (OSC52) を持ち、内側の nvim から見ても
  クリップボード対応が検出できる。

yazi は端末への動的クエリで protocol を判定するので、SSH 越しの裸の端末
(ghostty / kitty) では設定無しで画像プレビューが効く。tmux 内では yazi 側の
passthrough 対応を利用する。

ハマりどころ:

- tmux 3.7c の `terminal-features` に `graphics` はない。kitty graphics は
  tmux がネイティブ描画するのではなく、対応アプリが passthrough で端末へ送る。
- kitty は sixel 非対応なので、`terminal-features ',*:sixel'` を全クライアントへ
  宣言しない。sixel を使う場合は対応端末の TERM だけに限定する。
- クライアントが ghostty の場合、`~/.config/ghostty/config` の
  `term=xterm-256color` のままでも kitty graphics は動的クエリで検出される。
