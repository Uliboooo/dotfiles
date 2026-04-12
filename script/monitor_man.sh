#!/bin/bash

base_path="$HOME/dotfiles/.config/hypr/monitor"
moni_path="$HOME/dotfiles/.config/hypr/monitor/monitor.conf"

case "$1" in
dsgl) path="${base_path}/home.conf" ;;
lsgl) path="${base_path}/laptop.conf" ;;
dual) path="${base_path}/home_dual.conf" ;;
*) path=$2 ;;
esac

ln -fs "$path" "$moni_path"

eza -l "$moni_path"
