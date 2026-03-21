#!/bin/bash

ENV_PATH="$HOME/dotfiles/.config/hypr/env/IS_HYPR_DESIGN"

IS_HYPR_DESIGN=$(cat $ENV_PATH)

if [ "$IS_HYPR_DESIGN" -eq 0 ]; then
  ln -fs \
    "$HOME/dotfiles/.config/hypr/normal_visual.conf"\
    "$HOME/dotfiles/.config/hypr/visual.conf"
  echo '1' > $ENV_PATH
  notify-send "toggle-v" "toggle to normal hyprland design"
else
  ln -fs \
    "$HOME/dotfiles/.config/hypr/high_visual.conf"\
    "$HOME/dotfiles/.config/hypr/visual.conf"
  echo '0' > $ENV_PATH
  notify-send "toggle-v" "toggle to hypr hyprland design"
fi

hyprctl reload

