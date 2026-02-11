#!/bin/bash

hyprctl hyprpaper unload all

WALLPAPER=~/Pictures/wallpapers/KAF.jpg

hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"
