#!/bin/bash

get_all() {
  find $1 -maxdepth 1 -type f | sort
}

# $1: Pic Dir
get_first_path() {
  get_all "$1" | head -1
}

# $1: pattern
# $2: source files list
# return: next line from pattern
get_next_path() {
  REV_MODE=$3
  if (( $REV_MODE == 0 )); then
    MATCHED="$(echo "$2" | grep -Fx "$1" -A 1)"
  else
    MATCHED="$(echo "$2" | grep -Fx "$1" -B 1)"
  fi

  local MATCHED_LINES=$(echo "$MATCHED" | wc -l)

  if (( MATCHED_LINES != 2 )); then
    if (( REV_MODE == 0 )); then
      echo "$2" | head -n 1
    else
      echo "$2" | tail -n 1
    fi
  else
    if (( $REV_MODE == 0)); then
      echo "$MATCHED" | tail -1
    else
      echo "$MATCHED" | head -1
    fi
  fi
}

seq_or_rev() {
  local rev_mode=$1

  local wallpaper_dir=$2
  local current_paper_path="$HOME/dotfiles/.config/hypr/env/CURRENT_PAPER"

  if [[ -s "$current_paper_path" ]]; then
    local current_paper=$(cat $current_paper_path)
    if [[ -f "$current_paper" ]]; then
      local list=$(get_all ${wallpaper_dir})
      local next=$(get_next_path "$current_paper" "$list" "$rev_mode")
    else
      local next=$(get_first_path ${wallpaper_dir})
    fi
  else
    local next=$(get_first_path ${wallpaper_dir})
  fi

  echo "$next" > $current_paper_path
  echo "$next"
}

random_paper() {
  local wallpaper_dir=$1
  local current_paper_path="$HOME/dotfiles/.config/hypr/env/CURRENT_PAPER"
  local randomed_path=$(find "$wallpaper_dir" -type f | shuf -n 1)
  echo "$randomed_path" > $current_paper_path
  echo "$randomed_path"
}

WALLPAPER_DIR="$HOME/Pictures/wallpapers/"

case "$1" in
  seq)  wall_path=$(seq_or_rev 0 "$WALLPAPER_DIR")  ;;
  rev)  wall_path=$(seq_or_rev 1 "$WALLPAPER_DIR")  ;;
  rnd)  wall_path=$(random_paper "$WALLPAPER_DIR")  ;;
    *)
        echo "Usage: $0 <seq|rev|rnd>" >&2
        exit 1
        ;;
esac

mkdir -p /home/alice/dotfiles/.config/hypr/env
# awww
swww img "$wall_path" --transition-type center --transition-duration 0.5

