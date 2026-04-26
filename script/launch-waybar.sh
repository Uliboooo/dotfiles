#!/bin/bash
# script/launch-waybar.sh

# $1: style file

killall waybar || true
pkill waybar || true
sleep 0.5

STYLE="$HOME/dotfiles/.config/waybar/style.css"
BASE="$HOME/dotfiles/.config/waybar"

if [[ -e "$1" ]]; then
  STYLE="$1"
fi

case "$XDG_CURRENT_DESKTOP" in
Hyprland)
  waybar -c "$BASE/config.hypr.jsonc" -s "$STYLE" &
  ;;
niri)
  waybar -c "$BASE/config.niri.jsonc" -s "$STYLE" &
  ;;
sway:wlroots)
  waybar -c "$BASE/config.sway.jsonc" -s "$STYLE" &
  ;;
esac
