#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers/"

if [ -d "$WALLPAPER_DIR" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
    
    # Kill existing swaybg instances to avoid stacking
    pkill swaybg
    
    # Set the new wallpaper
    swaybg -i "$WALLPAPER" -m fill &
fi
