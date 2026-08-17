#!/usr/bin/env bash
# Capture the focused niri window from the already-composited screen.  Unlike
# niri's screenshot-window action this preserves the wallpaper/background under
# translucent terminals instead of writing their alpha channel to the PNG.
set -euo pipefail

window_json="$(niri msg --json focused-window)"
output_json="$(niri msg --json focused-output)"

# niri reports window geometry in logical pixels relative to the workspace
# view. `grim -g` accepts that same layout coordinate system; add the focused
# output's logical position for monitors that are not placed at 0,0.
geometry="$({
  jq -nr --argjson window "$window_json" --argjson output "$output_json" '
    $window.layout as $layout
    | $layout.tile_pos_in_workspace_view as $position
    | $layout.tile_size as $size
    | if $position == null then
        error("focused window has no visible tile position")
      else
        "\(($output.logical.x + $position[0]) | round),\(($output.logical.y + $position[1]) | round) \(($size[0]) | round)x\(($size[1]) | round)"
      end
  '
})"

screenshot_dir="$HOME/Desktop"
screenshot_path="$screenshot_dir/ScreenShot_$(date '+%Y-%m-%d_at_%H.%M.%S').png"
mkdir -p "$screenshot_dir"

grim -g "$geometry" "$screenshot_path"
wl-copy --type image/png < "$screenshot_path"
