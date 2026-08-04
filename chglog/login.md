# chglog / ログイン・greeter

display manager、PAM、gnome-keyring / gcr-ssh-agent まわり。

現行は **GDM**。2026-07-25 に greetd + tuigreet → greetd + ReGreet と移ったが、
2026-08-04 に GDM へ戻した(下の最新エントリ)。greetd 系を再提案する前に、
なぜ戻したかを読むこと。tuigreet は却下済み。

ここを壊すとログインできなくなる。作業前に世代ロールバックの手順と、
Ctrl+Alt+F2 の getty で逃げられることを確認しておく。

書き方は [../AGENT.md](../AGENT.md) を参照。

---

## 2026-08-04

### GDM の「power key 奪取」は実際には起きない(2026-07-25 の記述を訂正)

- 調査のみ。設定変更は無し

**inactive なセッションが持つ `block` インヒビタは、logind のキー処理判定から除外
される。** よって GDM の greeter が常駐していても、その gsd-media-keys が
`handle-power-key` / `handle-suspend-key` / `handle-hibernate-key` を握ったまま
niri / Hyprland から電源キーを奪うことは無い。2026-07-25 の「gsd-media-keys の
power key 奪取」はこの点で誤り。greeter が active なとき(= ログイン画面に居るとき)
だけ効くが、それは期待どおりの動作。

根拠(systemd 261.1、`nixpkgs#systemd.src` を展開して確認):

- `src/login/logind-action.c:374` … 電源 / サスペンド / ハイバネートキーの処理は
  `manager_is_inhibited(..., MANAGER_IS_INHIBITED_IGNORE_INACTIVE, ...)` で判定する
- `src/login/logind-inhibit.c:426-428` … そのフラグが立っていると
  `pidref_is_active_session(m, &i->pid) <= 0` のインヒビタを `continue` で飛ばす

**一方、sleep の delay インヒビタにはこのフラグが無く、inactive でも効く。**

- `src/login/logind-dbus.c:2158` … `MANAGER_IS_INHIBITED_CHECK_DELAY` だけを渡し、
  `IGNORE_INACTIVE` は渡していない

したがって GDM で実際に残るコストは、**greeter の gnome-shell / gsd-power が持つ
sleep delay ロックによるサスペンド開始の遅延**の方。上限は `InhibitDelayMaxSec`
(既定 5 秒)で、保持側が `PrepareForSleep` に応答すれば早く抜ける。この機は電源管理を
hypridle の 30 分アイドル hibernate に寄せている(`chglog/power.md`)ので、効くとしたら
そこ。

未確認:

- **実機で電源キーを試していない**。この機では電源キーをほとんど使わないため優先度を
  下げた。確認するなら niri セッションで電源キーを押し、niri 側のハンドラが動くかを見る
- サスペンド遅延も実測していない。`journalctl -b -u systemd-logind` で、サスペンド
  要求から `Entering sleep state` までの間隔を見る

ハマりどころ:

- **`systemd-inhibit --list` は active / inactive を区別せず全インヒビタを出す。**
  gdm の行が出ていること自体は「効いている」証拠にならない。上記の active 判定は
  list には現れない

### greetd + ReGreet をやめて GDM に戻した

- `modules/desktop.nix`
- `.config/greetd/regreet.css` (削除)
- `README/PaperDesign.md` / `AGENT.md` / `chglog.md`

**DM が `XDG_CURRENT_DESKTOP` を export しないと GNOME の設定アプリが起動しない。**
greetd + ReGreet では GNOME セッションで gnome-control-center が

```
Running gnome-control-center is only supported under GNOME and Unity, exiting
dbus-:1.2-org.gnome.Settings@0.service: Main process exited, code=exited, status=1/FAILURE
```

で即終了する(2026-08-02 の journal)。ユーザ判断で、個別に手当てするのではなく
DM ごと GDM に戻した。2026-07-25 の「GDM をやめた」判断を覆したことになる。

なぜ ReGreet だと壊れるか、確認した事実:

- `wayland-sessions/*.desktop` の `DesktopNames=` を読んでセッションリーダに
  `XDG_CURRENT_DESKTOP` / `XDG_SESSION_DESKTOP` を export するのは **DM の仕事**。
  `gdm-session-worker` にはこの 3 つの文字列が全部入っているが、
  `regreet` 0.4.0 のバイナリには `XDG_CURRENT_DESKTOP` の文字列自体が無い
- **`gnome-session` もこの変数をさわらない**。`gnome-session-service` /
  `gnome-session-init-worker` / `.gnome-session-wrapped` のいずれにも文字列が無く、
  DM が立てる前提になっている。Hyprland と niri は自前の設定
  (`hypr/config/env.lua`, `niri/config.kdl`)で立てているので greetd でも無傷だった。
  **壊れるのは GNOME だけ**という非対称はここから来る
- **`systemd --user` はログアウトしても生き残る**。前セッションの
  `systemctl --user import-environment` が入れた値が次のセッションに残る。実機で
  niri 稼働中の user manager に Hyprland 由来の `HYPRLAND_CMD` /
  `HL_INITIAL_WORKSPACE_TOKEN` が残っているのを確認した。`gnome-session` の
  init-worker は自分の環境を `UnsetAndSetEnvironment` で流し込むだけなので、
  **自分が持っていない変数は上書きされず古い値が生き続ける**
- `org.gnome.Settings` は D-Bus activation なので、環境は gnome-shell ではなく
  `systemd --user` 側から来る。gnome-shell の環境が正しくても関係なく落ちる
- 再現確認: `env XDG_CURRENT_DESKTOP=niri gnome-control-center` と
  `env -u XDG_CURRENT_DESKTOP gnome-control-center` の両方で同じメッセージが出る。
  `XDG_CURRENT_DESKTOP` はコロン区切りで、`GNOME` か `Unity` を含めば通る

ついでに分かった、直交する不具合(GDM に戻したので解消):

- **ReGreet の一覧に GNOME が出ていなかった**。`greetd.service` の `XDG_DATA_DIRS` は
  `/run/current-system/sw/share` だけで、そこの `wayland-sessions/` には
  `hyprland` / `hyprland-uwsm` / `niri` しか無い。GNOME は
  `services.displayManager.sessionPackages` にしか登録されず、実体は
  `services.displayManager.sessionData.desktops`(全セッションの linkFarm)側にある。
  `/var/lib/regreet/state.toml` も `seli = "Niri"` のままだった。
  greetd 系を再び使うなら `sessionData.desktops` を `XDG_DATA_DIRS` に足すこと
- ReGreet はセッションを名前キーの `HashMap<String, SessionInfo>` で持つ
  (バイナリのシンボルで確認)。探索パスを複数足しても重複表示にはならない

ハマりどころ:

- **`security.pam.services.greetd.enableGnomeKeyring` は消してよい**。既にある
  `login.enableGnomeKeyring = true` だけで gcr-ssh-agent の鍵解錠は保たれる。
  生成物で確認した経路は 2 本ある:
  - `/etc/pam.d/gdm-password` は `auth substack login` / `session include login` の
    4 行だけで、**自前の `pam_gnome_keyring` 行を持たない**。`/etc/pam.d/login` 側の
    auth / password / session(`auto_start`)の 3 行がそのまま効く
  - `/etc/pam.d/gdm-fingerprint` は自前の `pam_gnome_keyring` 行を持つ。こちらも
    `login.enableGnomeKeyring` で gate されている
    (`nixos/modules/services/display-managers/gdm.nix:551,557,640,646`)
  grep するなら `gdm-password` ではなく `login` を見ること。gdm-password を直接
  grep して「keyring が無い」と誤読しやすい
- **GDM のコストは 2026-07-25 のエントリのうち 2 つが復活する**。greeter 常駐
  (RSS 約 946MB)と、`gnome-shell` / `gsd-power` の sleep delay inhibitor。後者は
  `chglog/power.md` の hypridle 経由 hibernate と噛み合うので、サスペンド開始が遅いと
  感じたらここを疑う。3 つ目の「`gsd-media-keys` の power key 奪取」は**起きない**
  (同日の上のエントリで訂正済み)
- `services.xserver.enable = true` は GDM でもそのまま要る(残してある)
- Paper Design から greeter が外れた。GDM の greeter は gnome-shell そのもので
  `extraCss` 相当の口が無い。`README/PaperDesign.md` は「対象外」に書き換えた

**実機のログイン画面は未確認**(switch とログアウトが要る)。検証は
`nixos-rebuild build --flake .#desktop` が通ること、生成物に `greetd.service` が
無く `display-manager.service` が GDM になっていること、`/etc/pam.d/gdm-password` に
`pam_gnome_keyring` が入っていることまで。失敗したら Ctrl+Alt+F2 の getty か
前世代へのロールバックで戻す。

## 2026-07-27

### 4K 接続時に greeter の位置とドロップダウンが壊れる → cage を `-m last` に

- `modules/desktop.nix`

**cage の multi-monitor mode の既定は `extend` で、そのとき ReGreet の window は
全出力を連結したレイアウト全体に maximize される。** eDP-1(1920x1200) と
DP-1(3840x2160) を両方繋ぐと surface は幅 5760px の 1 枚になり、

- ログインカードは「連結レイアウトの中心」= 2 枚の継ぎ目付近に置かれ、位置が壊れて見える
- User / Session のドロップダウンもその巨大 surface 基準で配置され、ポップオーバが
  モニタを跨いで開く

という 2 症状が同じ原因で出る。`cageArgs = [ "-s" "-d" "-m" "last" ]` を渡して解決。

根拠(cage 0.3.1、`nix build nixpkgs#cage.src` で展開したソース):

- `cage.c:296` … `struct cg_server server = {.log_level = WLR_INFO}`。`output_mode` は
  0 = `CAGE_MULTI_OUTPUT_MODE_EXTEND`(`server.h:20-22`)。**`-m` を省くと extend**
- `view.c:94 view_position()` … primary view は `wlr_output_layout_get_box(..., NULL)`
  で取った**レイアウト全体の box** に `view_maximize()` される
- `output.c:304` … `last` モードでは新しい出力を有効にした時点で他を `output_disable()`
- `output.c:220` … その出力が外れると前の出力を自動で `output_enable()`。
  4K を抜けば eDP-1 に自動で戻る

ハマりどころ:

- **`cageArgs` を書くと既定値ごと置き換わる**。nixpkgs の既定は `[ "-s" "-d" ]`
  (`nixos/modules/programs/regreet.nix:41-47`)なので、`-s`(VT 切替許可)と `-d`(CSD 無効)
  を明示的に引き継ぐこと。落とすと Ctrl+Alt+F2 の逃げ道が消える
- **出力を名前で指定する手段は cage 0.3.1 には無い**。`-m` は `last` / `extend` の
  2 値だけ(`cage.c:271-275`)。「最後に接続された出力」に出るので、DRM の列挙順
  (通常 eDP-1 が先)により両挿し時は DP-1 側に出る。eDP-1 に固定したいなら cage を
  やめて sway / niri を greeter compositor にし output config を書くしかない
- **cage は出力スケールを設定できない**(scale 1 固定。`output.c` は
  `wlr_output->scale` を読むだけで設定しない)。4K 側では greeter の UI が物理的に
  小さく見える。`programs.regreet.font.size` を上げると eDP-1 単体のときも大きく
  なるトレードオフになるので、今回は触っていない
- niri / Hyprland 側の `output` 設定(scale 1.5、DP-1 を上に縦積み)は greeter には
  一切効かない。greeter は cage の世界にいるので、コンポジタの monitor 設定を
  いじっても直らない

検証は `nix eval --raw .#nixosConfigurations.desktop.config.services.greetd.settings.default_session.command`
で `cage -s -d -m last -- regreet` になることまで。**実機のログイン画面は未確認**
(switch とログアウトが要る)。

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

> **2026-08-04 訂正**: 下記のうち「`gsd-media-keys` が power key を奪う」は誤り。
> inactive セッションの block インヒビタは logind のキー処理から除外される。
> 同日の最新エントリを参照。sleep delay inhibitor の話はそのまま有効。

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
