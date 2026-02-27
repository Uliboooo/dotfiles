#!/bin/bash

killall waybar || true
pkill waybar || true
sleep 0.5

STYLE="$HOME/dotfiles/.config/waybar/style.css"
BASE="$HOME/dotfiles/.config/waybar"

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
