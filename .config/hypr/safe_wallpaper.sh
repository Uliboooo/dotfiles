#!/bin/bash

WALLPAPER="~/Pictures/safe_wallpaper/snow.jpg"
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$WALLPAPER"
hyprctl hyprpaper wallpaper ",$WALLPAPER"
