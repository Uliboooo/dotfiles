#!/usr/bin/env bash

get_all() {
  find $1 -maxdepth 1 -type f | sort
}

# $1: Pic Dir
get_first_path() {
  get_all "$1" | head -1
}

get_next_path() {
  REV_MODE=$3
  if (($REV_MODE == 0)); then
    MATCHED="$(echo "$2" | grep -Fx "$1" -A 1)"
  else
    MATCHED="$(echo "$2" | grep -Fx "$1" -B 1)"
  fi

  local MATCHED_LINES=$(echo "$MATCHED" | wc -l)

  if ((MATCHED_LINES != 2)); then
    if ((REV_MODE == 0)); then
      echo "$2" | head -n 1
    else
      echo "$2" | tail -n 1
    fi
  else
    if (($REV_MODE == 0)); then
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

  echo "$next" >$current_paper_path
  echo "$next"
}

random_paper() {
  local wallpaper_dir=$1
  local current_paper_path="$HOME/dotfiles/.config/hypr/env/CURRENT_PAPER"
  local randomed_path=$(find "$wallpaper_dir" -type f | shuf -n 1)
  echo "$randomed_path" >$current_paper_path
  echo "$randomed_path"
}

toggle_systemtimer() {
  if systemctl --user is-active --quiet cycle_wallpaper.timer; then
    systemctl --user stop cycle_wallpaper.timer && notify-send "stop slideshow" || notify-send "failed stop slideshow"
  else
    systemctl --user start cycle_wallpaper.timer && notify-send "start slideshow" || notify-send "failed start slideshow"
  fi
}

set_video() {
  echo "$HOME/Pictures/wallvideo/ok_geek_eyes_filt_cont.mp4"
}

toggle_video() {
  local v_pid=$(pgrep mpvpaper)

  if [ -n "$v_pid" ]; then
    pkill mpvpaper && notify-send "stop wallvideo" || notify-send "failed stop slideshow"
  else
    mpvpaper '*' ~/Pictures/wallvideo/ok_geek_eyes_24.mp4 -o "no-audio loop" --fork --mpv-args="--hwdec=auto-safe --vo=gpu" && notify-send "start wallvideo" || notify-send "failed start wallvideo"
  fi

}

WALLPAPER_DIR="$HOME/Pictures/wallpapers/"

case "$1" in
seq) wall_path=$(seq_or_rev 0 "$WALLPAPER_DIR") ;;
rev) wall_path=$(seq_or_rev 1 "$WALLPAPER_DIR") ;;
rnd) wall_path=$(random_paper "$WALLPAPER_DIR") ;;
vdo) toggle_video && exit 0 || exit 1 ;;
pse) toggle_systemtimer && exit 0 || exit 1 ;;
*) wall_path=$2 ;;
esac

mkdir -p $HOME/dotfiles/.config/hypr/env

# awww
awww img "$wall_path" --transition-type center --transition-duration 0.5
