#!/bin/bash

INTERNAL_MONITOR="eDP-1"
EXTERNAL_MONITOR="DP-1"

if ! hyprctl monitors | grep -q "Monitor $INTERNAL_MONITOR"; then
  hyprctl reload

else
  hyprctl keyword monitor "$INTERNAL_MONITOR, disable"
  hyprctl keyword monitor "$EXTERNAL_MONITOR, preferred, 0x0, 1"
fi
