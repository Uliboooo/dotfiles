#!/bin/bash

# モニター名の定義
INTERNAL="eDP-1"
EXTERNAL="DP-1"

# 外部モニター(DP-1)が接続されているか確認
if hyprctl monitors all | grep -q "Monitor $EXTERNAL"; then
    # 外部モニターがある場合: 外部をメイン(左)、内部をサブ(右下など)に配置
    hyprctl keyword monitor "$EXTERNAL, 3840x2160@60, 0x0, 1.5"
    hyprctl keyword monitor "$INTERNAL, 1920x1200@60, 2560x1440, 1"
    notify-send "Hyprland" "External Monitor Connected"
else
    # 外部モニターがない場合: 内部モニターのみ有効化（標準設定にリロード）
    hyprctl keyword monitor "$INTERNAL, preferred, auto, 1"
    hyprctl reload
    notify-send "Hyprland" "Internal Monitor Only"
fi
