#!/bin/bash

INTERNAL="eDP-1"
EXTERNAL="DP-1"

# 外部モニターが接続されているか確認
# grepの戻り値を利用するため直接ifに入れます
if hyprctl monitors all | grep -q "Monitor $EXTERNAL"; then
    case "$1" in
        0)
            hyprctl keyword monitor "${EXTERNAL}, 3840x2160, 0x0, 1.5"
            hyprctl keyword monitor "${INTERNAL}, 1920x1200, 320x1440, 1.0"
            notify-send "Hyprland" "All monitors enabled"
            ;;
        1)
            hyprctl keyword monitor "${EXTERNAL}, 3840x2160, 0x0, 1.5"
            hyprctl keyword monitor "${INTERNAL}, disable"
            notify-send "Hyprland" "External monitor only"
            ;;
        *)
            hyprctl keyword monitor "${INTERNAL}, preferred, auto, 1"
            hyprctl keyword monitor "${EXTERNAL}, disable"
            notify-send "Hyprland" "Default config (Internal only)"
            ;;
    esac
else
    # 外部モニターが見つからない場合
    hyprctl keyword monitor "${INTERNAL}, preferred, auto, 1"
    notify-send "Hyprland" "Internal Monitor Only (External not found)"
fi
