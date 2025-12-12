#!/bin/bash

INTERNAL_MONITOR="eDP-1"
EXTERNAL_MONITOR="DP-1"

IS_INTERNAL_DISABLED=$(hyprctl monitors | grep "Monitor $INTERNAL_MONITOR" | grep "enabled: no" | wc -l)

if [ "$IS_INTERNAL_DISABLED" -ge 1 ]; then
  echo "switching to dual mode"

  hyprctl keyword monitor "$INTERNAL_MONITOR, preferred, auto, 1"
  hyprctl keyword monitor "$EXTERNAL_MONITOR, preferred, auto, 1"
else
  echo "switching to external only"

  hyprctl keyword monitor "$INTERNAL_MONITOR, disable"
  hyprctl keyword monitor "$EXTERNAL_MONITOR, preferred, 0x0, 1"
fi
