#!/usr/bin/env bash
# Streams the current workspace's window list to a waybar custom module.
# Emits one JSON line per Hyprland event so waybar updates live (no polling).
set -euo pipefail

declare -A icons=(
  [ghostty]="󰊠"
  ["com.mitchellh.ghostty"]="󰊠"
  ["com.obsproject.Studio"]="󰻃"
  [google-chrome]=""
  [Google-chrome]=""
  [firefox]=""
  [kitty]="󰄛"
  [emacs]=""
  [org.gnome.Nautilus]=""
  ["com.discordapp.Discord.desktop"]=" "
)

declare -A names=(
  [ghostty]="Ghostty"
  ["com.mitchellh.ghostty"]="Ghostty"
  ["com.obsproject.Studio"]="OBS Studio"
  [google-chrome]="Chrome"
  [Google-chrome]="Chrome"
  [firefox]="Firefox"
  [kitty]="Kitty"
  [emacs]="Emacs"
  [org.gnome.Nautilus]="Nautilus"
)

xml_escape() {
  sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

print_state() {
  local focused_ws windows count text tooltip icon class title focused app_name

  focused_ws=$(hyprctl -j activeworkspace | jq '.id // empty')
  if [[ -z "$focused_ws" ]]; then
    echo '{"text": ""}'
    return
  fi

  local active_addr
  active_addr=$(hyprctl -j activewindow | jq -r '.address // ""')

  windows=$(hyprctl -j clients | jq --argjson ws "$focused_ws" --arg active "$active_addr" \
    '[.[] | select(.workspace.id == $ws)] | sort_by(.at[0], .at[1]) | map(. + {is_focused: (.address == $active)})')

  count=$(jq 'length' <<<"$windows")
  if [[ "$count" -eq 0 ]]; then
    echo '{"text": ""}'
    return
  fi

  text=""
  tooltip=""
  while IFS=$'\t' read -r class title focused; do
    icon="${icons[$class]:-$class}"
    if [[ "$focused" == "true" ]]; then
      app_name="${names[$class]:-$class}"
      text+="<span color='#cba6f7' size='108%'></span><span color='#1e1e2e' background='#cba6f7'>${icon} ${app_name}</span><span color='#cba6f7' size='108%'></span> │ "
    else
      text+="${icon} │ "
    fi
    tooltip+="$(xml_escape <<<"$title")"$'\n'
  done < <(jq -r '.[] | [.class, .title, .is_focused] | @tsv' <<<"$windows")

  text="${text% │ }"
  tooltip="${tooltip%$'\n'}"

  jq -nc --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'
}

print_state

nc -U "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r _; do
  print_state
done
