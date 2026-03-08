#!/bin/bash

get_all() {
  echo "$(find $1 -maxdepth 1 -type f | sort)"
}

# $1: Pic Dir
get_first_path() {
  echo $(get_all $1) | head -1
}

# $1: pattern
# $2: source files list
# return: next line from pattern
get_next_path() {
  MATCHED="$(echo "$2" | grep "$1" -A 1)"
  MATCHED_LINES=$(echo "$MATCHED" | wc -l)

  if (( MATCHED_LINES != 2 )); then
    echo "$2" | head -1
  else
    echo "$MATCHED" | tail -1
  fi
}

WALLPAPER_DIR="$HOME/Pictures/wallpapers/"
CURRENT_PAPER_PATH="$HOME/dotfiles/.config/hypr/env/CURRENT_PAPER"

if [ -s $CURRENT_PAPER_PATH ]; then
  CURRENT_PAPER=$(cat $CURRENT_PAPER_PATH)
  if [ -f $CURRENT_PAPER_PATH ]; then
    LIST=$(get_all $WALLPAPER_DIR)
    NEXT=$(get_next_path "$CURRENT_PAPER" "$LIST")
  else
    NEXT=$(get_first_path $WALLPAPER_DIR)
  fi
else
  NEXT=$(get_first_path $WALLPAPER_DIR)
fi

echo "$NEXT" > $CURRENT_PAPER_PATH
echo "$NEXT"

# awww
swww img "$NEXT" --transition-type center --transition-duration 0.5
