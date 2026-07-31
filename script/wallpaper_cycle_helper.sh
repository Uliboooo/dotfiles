#!/usr/bin/env bash

disable() {
  systemctl --user stop cycle_wallpaper.timer &&
    systemctl --user mask cycle_wallpaper.timer &&
    notify-send "wallpaper cycle disabled." -a "wch"
}

enable() {
  systemctl --user unmask cycle_wallpaper.timer &&
    systemctl --user start cycle_wallpaper.timer &&
    notify-send "wallpaper cycle enabled." -a "wch"

}

case "$1" in
disable)
  disable
  ;;
enable)
  enable
  ;;
toggle)
  if systemctl is-enabled --quiet cycle_wallpaper.timer; then
    disable
  else
    enable
  fi
  ;;
status)
  notify-send $(systemctl --user status cycle_wallpaper.timer)
  ;;
*)
  echo "unkown. support only enable, disable, status or toggle"
  exit 1
  ;;
esac
