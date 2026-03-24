#!/bin/bash

systemctl --user status cycle_wallpaper.timer | grep "Active"

if systemctl --user is-active --quiet cycle_wallpaper.timer; then
  notify-send "is active"
else
  notify-send "isn't active"
fi
