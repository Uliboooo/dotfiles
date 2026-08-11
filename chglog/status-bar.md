# Status bar

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
