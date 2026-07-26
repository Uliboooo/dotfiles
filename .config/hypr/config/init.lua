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
  hl.exec_cmd("fcitx5")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  -- hypridle はここで起動しない。systemd user サービス hypridle.service に一本化。
  -- 2 重起動するとロックの度に hyprlock が複数走り、ext-session-lock の敗者が
  -- ハングして pidof hyprlock が居座り、以後 lock_cmd が空振りする。
  hl.exec_cmd("swaync")
  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("wlmstr next seq")
  hl.exec_cmd("~/dotfiles/script/launch-waybar.sh")
  hl.exec_cmd("udiskie -a -t --notify")
  -- hl.exec_cmd("noctalia-shell")
end)
