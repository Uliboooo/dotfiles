# chglog / ログイン・greeter

display manager、PAM、gnome-keyring / gcr-ssh-agent まわり。

現行は **greetd + ReGreet**(cage 上の GTK4)。GDM と tuigreet はどちらも却下済みで、
理由は下のエントリにある。戻す提案をする前に読むこと。

ここを壊すとログインできなくなる。作業前に世代ロールバックの手順と、
Ctrl+Alt+F2 の getty で逃げられることを確認しておく。

書き方は [../AGENT.md](../AGENT.md) を参照。

---

## 2026-07-27

### Hyprland でも gcr-ssh-agent のソケットをクライアントへ渡す

- `.config/hypr/config/env.lua`

**Hyprland の標準セッションは `SSH_AUTH_SOCK` を設定しない**。`niri.desktop` は
`niri-session` を起動し、これはログインシェルを経由するため NixOS の `/etc/profile`
にある gcr 用の `SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"` が引き継がれる。対して
`hyprland.desktop` は `start-hyprland` を直接実行するので、その経路を通らず、端末では
`ssh-add -l` が `Could not open a connection to your authentication agent.` となる。

`env.lua` で同じソケットを Hyprland のクライアント環境に設定する。Hyprland 起動時の
`dbus-update-activation-environment --systemd --all` がこの値を systemd --user と D-Bus
にも同期するため、端末以外の GUI クライアントにも効く。gcr の実ソケット
`/run/user/1000/gcr/ssh` の存在を確認済み。`SSH_ASKPASS*` は設定しない（下記の既知の
制約を維持する）。

## 2026-07-25

### greeter を tuigreet から ReGreet に、Paper Design を適用

- `modules/desktop.nix`
- `.config/greetd/regreet.css` (新規)
- `README/PaperDesign.md`

ログイン画面だけが `README/PaperDesign.md` の規約の外にあった。**tuigreet では Paper
テーマは作れない**。`--theme` は ratatui の `Color::from_str`(tuigreet 0.9.1
`src/ui/common/style.rs:46`)に渡るので hex 自体は書けるが、greetd は tuigreet を
Linux VT 上で動かし、カーネルの VT は 24bit カラーの SGR を解釈せず 16 色に落とす。
`paper #f1eee5` / `ink #2d302b` / `rose #d38ca0` は出せない。そもそも 1px の罫線・
角丸 0・Monaspace Radon は TTY セル文字には存在しない概念で、色を当てられるのも
`container / time / text / border / title / greet / prompt / input / action / button`
の 10 箇所だけ。

ReGreet は GTK4 なので `extraCss` に Waybar / SwayNC と同じ CSS が書ける。GDM を
やめた理由(greeter 常駐 / gsd-media-keys の power key 奪取 / sleep inhibitor)は
cage + ReGreet には当てはまらない。ログイン時に cage ごと終了し、
gnome-settings-daemon 一式も起動しない。

ハマりどころ:

- **`XDG_DATA_DIRS` が要る**。tuigreet の `--sessions` と同じ罠。ReGreet は
  `XDG_DATA_DIRS` の各要素に `/xsessions:/wayland-sessions` を足して探す
  (0.4.0 `src/sysutil.rs:110-124`)が、`systemctl show greetd.service -p Environment`
  で確認したとおり greetd.service には `XDG_DATA_DIRS` が無く、既定値
  `/usr/share/xsessions:/usr/share/wayland-sessions` は NixOS に無い。放置すると
  セッション一覧が空になる。`systemd.services.greetd.environment` で
  `/run/current-system/sw/share` を渡す(GTK のテーマ/アイコン探索先も兼ねる)。
- **`default_session.command` を書かない**。`programs.regreet` が `mkDefault` で
  `dbus-run-session cage -s -d -- regreet` を入れる。tuigreet 時代の `command` を
  残すとそちらが勝つ。`user = "greeter"` も greetd module 側の `mkDefault` がある。
- `security.pam.services.greetd.enableGnomeKeyring = true` は**そのまま維持**。PAM
  サービス名は greeter を替えても `greetd` のままで、gcr-ssh-agent の鍵解錠が依存。
- nixpkgs の attribute は **`pkgs.regreet`(0.4.0)**。`pkgs.greetd.regreet` は無い。
- ReGreet の widget に CSS id は付かない。`#[name = ...]`(`src/gui/templates.rs`)は
  relm4 の Rust フィールド名で CSS には出ないので、要素セレクタと Adwaita の
  クラス(`.suggested-action` / `.destructive-action` / `.background`)で当てる。
- `[GTK] application_prefer_dark_theme` の既定は true。false を明示しないと
  Adwaita の暗い地が残る。
- `extraCss` に path を渡すと Nix store にコピーされる。home-manager 側の
  `mkOutOfStoreSymlink` と違い、CSS を直しても `nixos-rebuild switch` するまで
  反映されない。色を詰める間は往復が要る。

検証は `nixos-rebuild build --flake .#desktop` と生成物まで。`greetd.toml` の
command が cage + regreet になり tuigreet が消えたこと、greetd.service に
`Environment="XDG_DATA_DIRS=/run/current-system/sw/share"` が入ったこと、
`/etc/greetd/regreet.toml` が `font_name = "Monaspace Radon Var 12"` /
`application_prefer_dark_theme = false` になったことを確認済み。**実機のログイン画面は
未確認**(switch とログアウトが要る)。失敗時は Ctrl+Alt+F2 の getty か前世代で戻す。

### GDM をやめて greetd + tuigreet に

- `modules/desktop.nix`

GDM はログイン後も greeter セッションが常駐し続ける(gnome-shell 一式で RSS 約
946MB)。さらにその `gsd-media-keys` が `handle-power-key` / `handle-suspend-key` /
`handle-hibernate-key` を block モードで握って niri 側の power-key 処理と競合し、
`gnome-shell` と `gsd-power` が sleep の delay inhibitor を持つのでサスペンド開始も
遅れていた。tuigreet は TTY 上で動きログイン後に終了するのでいずれも起きない。

- `--sessions /run/current-system/sw/share/wayland-sessions` は必須。tuigreet の既定の
  探索先は `/usr/share/wayland-sessions` で NixOS には無く、セッション一覧が空になる。
- `security.pam.services.greetd.enableGnomeKeyring = true` を忘れないこと。これが無いと
  login キーリングが解錠されず、gcr-ssh-agent が `~/.ssh/id_ed25519` のパスフレーズを
  取り出せずに GitHub への SSH が固まる。
- nixpkgs 側で **`greetd.tuigreet` は存在せず、トップレベルの `pkgs.tuigreet`**(0.9.1)。

なお tuigreet はこの後 ReGreet に置き換えた(同日、上のエントリ)。
