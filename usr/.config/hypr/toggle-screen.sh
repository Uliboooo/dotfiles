#!/bin/bash

INTERNAL_MONITOR="eDP-1"
EXTERNAL_MONITOR="DP-1"

if ! hyprctl monitors | grep -q "Monitor $INTERNAL_MONITOR"; then
  hyprctl keyword monitor "$EXTERNAL_MONITOR, 3840x2160, 0x0, 1.5"
  hyprctl keyword monitor "$INTERNAL_MONITOR, 1920x1200, 320x1440, 1.0"
else
  hyprctl reload
fi
