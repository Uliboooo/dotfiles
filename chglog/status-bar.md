# Status bar

## 2026-08-09

### Noctalia を既定にし、Waybar と排他化

Noctalia は `graphical-session.target` から自動起動する。Waybar の自動起動は外し、
双方の unit に `Conflicts=` を設定したため、`systemctl --user start waybar` と
`systemctl --user start noctalia` で安全に切り替えられる。
