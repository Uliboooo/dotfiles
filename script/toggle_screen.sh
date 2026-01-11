#!/bin/bash

INTERNAL="eDP-1"
EXTERNAL="DP-1"

# 外部モニターが接続されているか確認
if hyprctl monitors all | grep -q "Monitor $EXTERNAL"; then
    
    # 内蔵モニターが現在「有効（アクティブ）」か確認
    # grepにスペースを追加し、より正確にマッチングさせます
    if hyprctl monitors | grep -q "Monitor $INTERNAL"; then
        # 内蔵モニターを無効化し、外部モニターのみにする
        # 0x0の位置設定などを明示的に指定
        hyprctl keyword monitor "$INTERNAL, disable"
        hyprctl keyword monitor "$EXTERNAL, 3840x2160@60, 0x0, 1.5"
        
        notify-send "Hyprland" "Internal monitor DISABLED"
    else
        # 内蔵モニターを再有効化（デフォルト設定に戻す）
        # reloadよりも明示的な設定の方が確実です
        hyprctl keyword monitor "$INTERNAL, preferred, auto, 1"
        notify-send "Hyprland" "Internal monitor ENABLED"
    fi
else
    # 外部モニターがない場合は内蔵モニターを強制有効
    hyprctl keyword monitor "$INTERNAL, preferred, auto, 1"
    notify-send "Hyprland" "Internal Monitor Only (External not found)"
fi
