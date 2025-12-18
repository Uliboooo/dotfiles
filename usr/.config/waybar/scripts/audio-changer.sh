#!/bin/bash

# --- 1. 設定: 内蔵オーディオの定義 ---
# 内蔵カードの名前を自動取得（たいてい alsa_card.pci... で始まります）
CARD_NAME=$(pactl list cards short | grep alsa_card.pci | cut -f2 | head -n1)
# ログから判明したプロファイル名
PROF_HP="HiFi (Headphones, Mic1, Mic2)"
PROF_SPK="HiFi (Mic1, Mic2, Speaker)"

# メニューの表示名
NAME_HP="Built-in Headphones"
NAME_SPK="Built-in Speakers"

# --- 2. 外部デバイス（Bluetooth/USBなど）のリスト取得 ---
# 形式: "ID: デバイス名"
# ※内蔵オーディオ(pci)は重複表示を避けるためgrep -vで除外していますが、
#   もし外部デバイスが出ない場合は grep -v 部分を削除してください。
OTHER_SINKS=$(pactl list short sinks | grep -v "pci" | awk '{print $1 ": " $2}')

# --- 3. メニューの構築 ---
# 内蔵オプション2つ + 外部デバイスリスト
if [ -n "$OTHER_SINKS" ]; then
    MENU="$NAME_HP\n$NAME_SPK\n$OTHER_SINKS"
else
    MENU="$NAME_HP\n$NAME_SPK"
fi

# --- 4. Wofi表示 ---
SELECTED=$(echo -e "$MENU" | wofi --dmenu --cache-file /dev/null --prompt "Audio Output" --width 400 --height 250)

if [ -z "$SELECTED" ]; then
    exit 0
fi

# --- 5. 切り替え処理 ---
if [ "$SELECTED" == "$NAME_HP" ]; then
    # 内蔵ヘッドフォンへ
    pactl set-card-profile "$CARD_NAME" "$PROF_HP"
    notify-send "Audio" "Switched to Headphones"

elif [ "$SELECTED" == "$NAME_SPK" ]; then
    # 内蔵スピーカーへ
    pactl set-card-profile "$CARD_NAME" "$PROF_SPK"
    notify-send "Audio" "Switched to Speakers"

else
    # その他のデバイス（IDを取得して切り替え）
    SINK_ID=$(echo "$SELECTED" | cut -d':' -f1)
    if [ -n "$SINK_ID" ]; then
        pactl set-default-sink "$SINK_ID"

        # 再生中のストリームも移動
        pactl list short sink-inputs | cut -f1 | while read stream; do
            pactl move-sink-input "$stream" "$SINK_ID"
        done

        notify-send "Audio" "Switched to External Device"
    fi
fi
