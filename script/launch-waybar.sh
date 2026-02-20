#!/bin/bash

killall waybar || true
pkill waybar || true
sleep 0.5

if pgrep -x Hyprland > /dev/null; then
    waybar -c $HOME/dotfiles/.config/waybar/config.hypr.jsonc -s $HOME/dotfiles/.config/waybar/style.css &
    echo "spawn waybay for hyprland"
elif pgrep -x niri > /dev/null; then
    waybar -c $HOME/dotfiles/.config/waybar/config.niri.jsonc -s $HOME/dotfiles/.config/waybar/style.css &
    echo "spawn waybar for niri"
fi
