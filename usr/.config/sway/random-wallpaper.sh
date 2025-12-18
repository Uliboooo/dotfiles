#!/bin/bash

# 壁紙が保存されているディレクトリのパス
WALLPAPER_DIR="$HOME/Pictures/wallpapers/"

# ディレクトリが存在するか確認
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Directory $WALLPAPER_DIR does not exist."
    exit 1
fi

# ランダムに1枚選出 (findで画像ファイルを取得し、shufでランダム化)
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | shuf -n 1)

# 壁紙を適用
if [ -n "$WALLPAPER" ]; then
    # すべての出力 (output *) に対して壁紙を設定
    swaymsg "output * bg '$WALLPAPER' fill"
else
    echo "No images found in $WALLPAPER_DIR"
    exit 1
fi
