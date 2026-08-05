#!/usr/bin/env bash
set -uo pipefail

# script/launch-swaync.sh

# $1: style file, or the named theme "rose-pine-neon"

# swaync.service (graphical-session.target 配下、SwayNotificationCenter 同梱) が
# 引数なしの swaync を先に起動して org.freedesktop.Notifications を掴む。
# 二重起動した swaync は DBus 名の奪い合いに負けて即終了するので、先に止めて
# から -s 付きで起動し直す。明示的な stop なので Restart=on-failure では
# 自動復帰しない。

pkill swaync || true
systemctl --user stop swaync.service 2>/dev/null || true
sleep 0.5

BASE="$HOME/dotfiles/.config/swaync"
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
    printf 'SwayNC style not found: %s\n' "$arg1" >&2
    exit 1
  fi
  ;;
esac

# ysh の `fork { ... }` 相当。セッションから切り離して起動元の終了に巻き込まれないようにする
setsid swaync -s "$STYLE" >/dev/null 2>&1 &
