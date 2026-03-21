#!/bin/bash

TARGET=$1

if command -v -- "rg" >/dev/null 2>&1; then
  GREP="rg"
else
  GREP="grep"
fi

SYS_RES=$(ls "/usr/share/applications/" | $GREP -i "$1")
LAL_RES=$(ls "/usr/local/share/applications/" | $GREP -i "$1")
FLT_RES=$(flatpak list | "$GREP" -i "$1")

NOT_FOUND=1
[[ -n "$SYS_RES" ]] && { NOT_FOUND=0; echo "At usr/share/applications";  printf "%s\n" "$SYS_RES" | sed 's/^/    /'; }
[[ -n "$LAL_RES" ]] && { NOT_FOUND=0; echo "At usr/local/share/applications"; printf "%s\n" "$LAL_RES" | sed 's/^/    /'; }
[[ -n "$FLT_RES" ]] && { NOT_FOUND=0; echo "At flatpak"; printf "%s\n" "$FLT_RES" | sed 's/^/    /'; }

if (( $NOT_FOUND == 1 )); then
  echo "$1 is not found in this machine :("
  exit 1
else
  exit 0
fi

