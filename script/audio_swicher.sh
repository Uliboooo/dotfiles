#!/usr/bin/env bash
set -uo pipefail

# 1. Sinks（出力）セクションから次のセクション（Sources）までの間だけを抜き出す
# 2. その中からIDと名前の行を取得
# 3. デフォルトを示す '*' を削除し、行頭の空白を整える
devices=$(wpctl status | sed -n '/Sinks:/,/Sources:/p' | grep -oP '\d+\. .*' | sed 's/^\*//; s/^[ \t]*//')

# rofiで選択
chosen=$(printf '%s\n' "$devices" | rofi -dmenu -p "󰓃 Select Output: ")

if [[ -n "$chosen" ]]; then
  # 行頭のID数値だけを抽出
  id=$(printf '%s\n' "$chosen" | grep -oP '^\d+')

  if wpctl set-default "$id"; then
    notify-send "Audio Switcher" "Output changed to:\n$chosen" -i audio-speakers -t 2000
  else
    notify-send "Audio Switcher" "Failed to switch" -u critical
  fi
fi
