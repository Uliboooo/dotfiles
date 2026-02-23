#!/bin/bash

# Get external monitor name (the first one that isn't eDP-1)
EXTERNAL_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name' | head -n 1)

if [ -z "$EXTERNAL_MONITOR" ]; then
    # No external monitor, ensure eDP-1 is enabled (failsafe)
    hyprctl keyword monitor "eDP-1, 1920x1200, 320x1440, 1.0"
    exit 0
fi

# LID state check
LID_STATE=$(cat /proc/acpi/button/lid/LID/state | awk '{print $2}')

if [ "$LID_STATE" = "closed" ]; then
    # Move all workspaces to the external monitor
    for ws in $(hyprctl workspaces -j | jq -r '.[] | .id'); do
        hyprctl dispatch moveworkspacetomonitor "$ws" "$EXTERNAL_MONITOR"
    done
    # Disable internal display
    hyprctl keyword monitor "eDP-1, disable"
else
    # Lid is open, restore internal display
    hyprctl keyword monitor "eDP-1, 1920x1200, 320x1440, 1.0"
fi
