#!/bin/bash

WALLPAPER="~/Pictures/safe_wallpaper/8k_plasma.png"
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"
