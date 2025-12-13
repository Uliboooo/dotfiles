#!/usr/bin/env bash

LOCK="$HOME/.cache/wallpaper.lock"
WALLPAPER_DIR="$HOME/Pictures/wallpapers/"

if [[ -f "$LOCK" ]]; then
  exit 0
fi

WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# apply wallpaper
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"
