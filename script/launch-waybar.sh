#!/bin/bash

killall waybar || true
pkill waybar || true
sleep 0.5

waybar -c $HOME/dotfiles/.config/waybar/config.niri.jsonc -s $HOME/dotfiles/.config/waybar/style.css &
