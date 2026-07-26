#!/usr/bin/env bash
set -uo pipefail

# script/launch-waybar.sh

# $1: style file

pkill waybar || true
sleep 0.5

BASE="$HOME/dotfiles/.config/waybar"
STYLE="$BASE/style.css"

arg1="${1:-}"
if [[ -n "$arg1" && -e "$arg1" ]]; then
  STYLE="$arg1"
fi

# ysh の `fork { ... }` 相当。セッションから切り離して起動元の終了に巻き込まれないようにする
launch() {
  setsid waybar -c "$1" -s "$STYLE" >/dev/null 2>&1 &
}

case "${XDG_CURRENT_DESKTOP:-}" in
Hyprland) launch "$BASE/config.hypr.jsonc" ;;
niri) launch "$BASE/config.niri.jsonc" ;;
sway:wlroots) launch "$BASE/config.sway.jsonc" ;;
esac
