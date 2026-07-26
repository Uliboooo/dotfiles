#!/usr/bin/env bash
set -uo pipefail

# 壁紙の seq/rev/rnd 巡回は wlmstr (github:Uliboooo/wlmstr) が担当する。
# wlmstr に無い 2 機能だけをここに残す。
#
#   vdo  mpvpaper による動画壁紙のトグル
#   pse  cycle_wallpaper.timer (スライドショー) のトグル

WALLVIDEO_PATH="$HOME/Pictures/wallvideo/ok_geek_eyes_24.mp4"
MPVPAPER_ARGS="--hwdec=auto-safe --panscan=1.0"

toggle_video() {
  if pgrep -x mpvpaper >/dev/null 2>&1; then
    if pkill -x mpvpaper; then
      notify-send "Stop wallvideo"
    else
      notify-send "Failed stop wallvideo"
      return 1
    fi
  else
    if mpvpaper '*' "$WALLVIDEO_PATH" --fork -o "no-audio loop" --mpv-args="$MPVPAPER_ARGS"; then
      notify-send "Start wallvideo"
    else
      notify-send "Failed start wallvideo"
      return 1
    fi
  fi
}

toggle_systemtimer() {
  if systemctl --user is-active --quiet cycle_wallpaper.timer; then
    if systemctl --user stop cycle_wallpaper.timer; then
      notify-send "Stop slideshow"
    else
      notify-send "Failed stop slideshow"
      return 1
    fi
  else
    if systemctl --user start cycle_wallpaper.timer; then
      notify-send "Start slideshow"
    else
      notify-send "Failed start slideshow"
      return 1
    fi
  fi
}

case "${1:-}" in
vdo) toggle_video ;;
pse) toggle_systemtimer ;;
*)
  echo "usage: ${0##*/} {vdo|pse}" >&2
  echo "  巡回 (seq/pre/rnd) は 'wlmstr next <dir>' を使う" >&2
  exit 2
  ;;
esac
