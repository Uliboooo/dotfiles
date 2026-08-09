hl.on("hyprland.start", function()
  -- 環境変数の伝播 → portal 再起動 → polkit agent の順序を保証するため 1 コマンドに
  -- まとめる。exec_cmd は fire-and-forget なので別行に分けると競合し、portal が古い
  -- WAYLAND_DISPLAY / HYPRLAND_INSTANCE_SIGNATURE を掴んで起動しうる。
  --
  -- portal を restart するのは前セッションの残骸を確実に置き換えるため。
  -- hyprland.desktop 直起動では graphical-session.target が上がらないので
  -- ユニットの PartOf= が効かず、Hyprland を再起動しても前の
  -- xdg-desktop-portal-hyprland が生き残る。そいつは Wayland ソケットの対向が
  -- 消えた後もイベントループを空回りし続け、CPU を 1.5 コア以上食い続ける
  -- (hyprwm/xdg-desktop-portal-hyprland#103, #116)。同時にスクリーン共有と
  -- スクリーンショットも死ぬ。
  hl.exec_cmd(
    "dbus-update-activation-environment --systemd --all; "
      .. "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP; "
      .. "systemctl --user restart xdg-desktop-portal.service xdg-desktop-portal-hyprland.service; "
      .. "systemctl --user reset-failed hyprpolkitagent.service; "
      .. "systemctl --user start hyprpolkitagent.service"
  )
  -- セッション部品 (swaync / waybar / udiskie / cliphist / awww-daemon /
  -- wlmstr / swayidle / hyprpolkitagent) はここで起動しない。すべて systemd user
  -- サービス (modules/desktop.nix, graphical-session.target 配下) に移管した。
  -- ここで exec すると二重起動になる。fcitx5 は明示 unit を持たせず D-Bus
  -- アクティベーション (NixOS i18n.inputMethod) に任せる。graphical-session 直起動だと
  -- コンポジタの zwp_input_method_v2 が ready になる前に張り付いて失敗し、
  -- `fcitx5 -r` しないと日本語入力が復活しなくなるため。
  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
  -- hl.exec_cmd("noctalia-shell")
end)
