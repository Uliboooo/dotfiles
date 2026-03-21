#!/usr/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers/"
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

echo $WALLPAPER

case "$XDG_CURRENT_DESKTOP" in
Hyprland)
  hyprctl hyprpaper unload all
  hyprctl hyprpaper preload "$WALLPAPER"
  hyprctl hyprpaper wallpaper ",$WALLPAPER"
  ;;
niri)
  pkill -x swaybg 2>/dev/null
  swaybg -i "$WALLPAPER" -m fill &
  ;;
sway:wlroots)
  pkill -x swaybg 2>/dev/null
  swaybg -i "$WALLPAPER" -m fill &
  ;;
esac
