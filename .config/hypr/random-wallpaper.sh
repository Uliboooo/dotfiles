#!/usr/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers/"
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"
