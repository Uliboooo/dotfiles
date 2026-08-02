#!/usr/bin/env bash

dir=$1

fd . $1 |
  while read -r img; do
    printf '%s\0icon\x1f%s\n' \
      "${img##*/}" \
      "$img" # "$(basename "$img")" \
  done |
  rofi -dmenu -show-icons -p " " -theme-str '
window {
    height: 90%;
}

listview {
    dynamic: true;
    lines: 1000;
}'
