# Status bar

## 2026-08-17

### Waybar から rofi のシステム操作メニューを開く

触ったファイル: `script/system_control.sh`, `.config/waybar/config.niri.jsonc`

Noctalia の Quick Settings に依存せず、Waybar の sliders アイコンから Bash 製の rofi
メニューを開けるようにした。音量・PipeWire の入出力、NetworkManager の Wi-Fi、既知の
Bluetooth 機器、輝度、セッション／電源操作を、それぞれ対応する標準 CLI だけで扱う。
表示行とは別に Bash 配列で node ID / SSID / MAC address を保持し、空白を含む名前を
そのまま操作対象へ渡せるようにしている。

## 2026-08-17

### Waybar と SwayNC の通知 DBus 所有を連動

触ったファイル: `modules/desktop.nix`

Waybar は `swaync.service` を `Requires=` / `After=` し、SwayNC は
`Type=dbus` と `BusName=org.freedesktop.Notifications` を使う。従って SwayNC が
通知 DBus 名を取得するまで Waybar は起動完了にならない。SwayNC の
`PartOf=waybar.service` により、Noctalia の `Conflicts=waybar.service` が Waybar を
停止すると SwayNC も停止する。`Conflicts=` は停止した Noctalia を自動再起動しないため、
Waybar 停止後の Noctalia 復帰は引き続き明示的に `systemctl --user start noctalia` する。

## 2026-08-17

### Waybar の niri セッションも Paper Design に統一

触ったファイル: `modules/desktop.nix`

niri セッションだけが `style.rose-pine-moon-neon.css` を明示指定していたため、Paper
Design の既定 `style.css` を指定するよう戻した。SwayNC は現在 Noctalia との通知 DBus
競合を避けるため起動していないが、保持している既定 `style.css` / `colors.css` は既に
Paper Design である。

## 2026-08-11

### 通知デーモンを Noctalia に一本化

触ったファイル: `modules/desktop.nix`, `home/common_user.nix`, `.config/niri/config.kdl`, `.config/hypr/config/binds.lua`

Noctalia と SwayNC はともに Desktop Notifications の DBus 名を提供するため、同時に
起動すると表示先・履歴・DND の担当が競合する。SwayNC の systemd user service、
パッケージ、Home Manager の設定リンクを外し、`Super+C` は Noctalia の
`notifications toggleHistory` IPC を呼ぶよう統一した。

## 2026-08-09

### Noctalia を既定にし、Waybar と排他化

Noctalia は `graphical-session.target` から自動起動する。Waybar の自動起動は外し、
双方の unit に `Conflicts=` を設定したため、`systemctl --user start waybar` と
`systemctl --user start noctalia` で安全に切り替えられる。
