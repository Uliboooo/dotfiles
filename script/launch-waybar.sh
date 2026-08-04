#!/usr/bin/env bash
set -uo pipefail

# script/launch-waybar.sh

# $1: style file, or the named theme "rose-pine-neon"

pkill waybar || true
sleep 0.5

BASE="$HOME/dotfiles/.config/waybar"
STYLE="$BASE/style.css"

arg1="${1:-}"
case "$arg1" in
rose-pine-neon)
  STYLE="$BASE/style.rose-pine-moon-neon.css"
  ;;
"")
  ;;
*)
  if [[ -e "$arg1" ]]; then
    STYLE="$arg1"
  else
    printf 'Waybar style not found: %s\n' "$arg1" >&2
    exit 1
  fi
  ;;
esac

# ysh の `fork { ... }` 相当。セッションから切り離して起動元の終了に巻き込まれないようにする
launch() {
  setsid waybar -c "$1" -s "$STYLE" >/dev/null 2>&1 &
}

case "${XDG_CURRENT_DESKTOP:-}" in
Hyprland) launch "$BASE/config.hypr.jsonc" ;;
niri) launch "$BASE/config.niri.jsonc" ;;
sway:wlroots) launch "$BASE/config.sway.jsonc" ;;
esac
