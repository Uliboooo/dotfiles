#!/bin/bash

# 1. Sinks（出力）セクションから次のセクション（Sources）までの間だけを抜き出す
# 2. その中からIDと名前の行を取得
# 3. デフォルトを示す '*' を削除し、行頭の空白を整える
devices=$(wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -oP '\d+\. .*' | sed 's/^\*//; s/^[ \t]*//')

# fuzzelで選択
chosen=$(echo "$devices" | fuzzel --dmenu -p "󰓃 Select Output: " --width 60)

if [ -n "$chosen" ]; then
    # 行頭のID数値だけを抽出
    id=$(echo "$chosen" | grep -oP '^\d+')
    
    if wpctl set-default "$id"; then
        notify-send "Audio Switcher" "Output changed to:\n$chosen" -i audio-speakers -t 2000
    else
        notify-send "Audio Switcher" "Failed to switch" -u critical
    fi
fi
