#!/usr/bin/env bash
# A small rofi front-end for the desktop controls used by Waybar.

rofi_index() {
  local prompt=$1 selection
  shift
  ((${#@})) || return 1
  selection=$(printf '%s\n' "$@" | rofi -dmenu -i -p "$prompt" -format i) || return 1
  [[ $selection =~ ^[0-9]+$ ]] || return 1
  printf '%s\n' "$selection"
}

rofi_input() {
  rofi -dmenu -password -p "$1" < /dev/null
}

confirm() {
  local answer
  answer=$(rofi_index "$1" "○ Cancel" "● Confirm") || return 1
  [[ $answer == 1 ]]
}

default_node_id() {
  wpctl inspect "$1" 2>/dev/null | sed -nE '1{s/^id ([0-9]+).*/\1/p;}'
}

node_name() {
  local id=$1 class=$2
  pw-dump | jq -r --argjson id "$id" --arg class "$class" '
    .[]
    | select(.id == $id and .type == "PipeWire:Interface:Node")
    | select(.info.props["media.class"] == $class)
    | (.info.props["node.description"] // .info.props["node.nick"] // .info.props["node.name"] // "Unknown")
  ' | head -n 1
}

node_records() {
  pw-dump | jq -r --arg class "$1" '
    .[]
    | select(.type == "PipeWire:Interface:Node")
    | select(.info.props["media.class"] == $class)
    | [.id, (.info.props["node.description"] // .info.props["node.nick"] // .info.props["node.name"] // "Unknown")]
    | @tsv
  ' | sort -n
}

audio_device_menu() {
  local class=$1 target=$2 title=$3 default_id record id name index
  local -a labels=() ids=()
  default_id=$(default_node_id "$target")
  while IFS=$'\t' read -r id name; do
    [[ -n $id ]] || continue
    ids+=("$id")
    if [[ $id == "$default_id" ]]; then
      labels+=("● $name")
    else
      labels+=("○ $name")
    fi
  done < <(node_records "$class")
  labels+=("← Back")

  index=$(rofi_index "$title" "${labels[@]}") || return
  ((index < ${#ids[@]})) || return
  wpctl set-default "${ids[index]}"
}

audio_menu() {
  local index default_id default_name volume
  while :; do
    default_id=$(default_node_id '@DEFAULT_AUDIO_SINK@')
    default_name=$(node_name "$default_id" 'Audio/Sink')
    volume=$(wpctl get-volume '@DEFAULT_AUDIO_SINK@' 2>/dev/null | sed 's/^Volume: //')
    index=$(rofi_index 'Audio' \
      "● Output: ${default_name:-Unknown} (${volume:-unavailable})" \
      '○ Volume up 5%' \
      '○ Volume down 5%' \
      '○ Toggle mute' \
      '○ Select output device' \
      '○ Select microphone' \
      '← Back') || return
    case $index in
      0) ;;
      1) wpctl set-volume '@DEFAULT_AUDIO_SINK@' 5%+ ;;
      2) wpctl set-volume '@DEFAULT_AUDIO_SINK@' 5%- ;;
      3) wpctl set-mute '@DEFAULT_AUDIO_SINK@' toggle ;;
      4) audio_device_menu 'Audio/Sink' '@DEFAULT_AUDIO_SINK@' 'Audio output' ;;
      5) audio_device_menu 'Audio/Source' '@DEFAULT_AUDIO_SOURCE@' 'Microphone' ;;
      *) return ;;
    esac
  done
}

wifi_device() {
  nmcli -t -f DEVICE,TYPE device status | awk -F: '$2 == "wifi" { print $1; exit }'
}

wifi_current_ssid() {
  nmcli -t -f ACTIVE,SSID device wifi 2>/dev/null |
    awk -F: '$1 == "yes" { sub(/^yes:/, ""); print; exit }'
}

wifi_network_menu() {
  local current record in_use ssid signal security index password
  local -a labels=() ssids=() securities=()
  current=$(wifi_current_ssid)
  declare -A seen=()

  while IFS=: read -r in_use ssid signal security; do
    [[ -n $ssid && -z ${seen[$ssid]+x} ]] || continue
    seen[$ssid]=1
    ssids+=("$ssid")
    securities+=("$security")
    if [[ $ssid == "$current" || $in_use == '*' ]]; then
      labels+=("● $ssid  ${signal:-0}%  ${security:-Open}")
    else
      labels+=("○ $ssid  ${signal:-0}%  ${security:-Open}")
    fi
  done < <(nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan auto 2>/dev/null)
  labels+=("← Back")

  index=$(rofi_index 'Wi-Fi networks' "${labels[@]}") || return
  ((index < ${#ssids[@]})) || return
  ssid=${ssids[index]}
  security=${securities[index]}

  if nmcli -t -f NAME connection show | grep -Fqx -- "$ssid"; then
    nmcli connection up id "$ssid"
  elif [[ -n $security && $security != '--' ]]; then
    password=$(rofi_input "Password for $ssid") || return
    [[ -n $password ]] && nmcli device wifi connect "$ssid" password "$password"
  else
    nmcli device wifi connect "$ssid"
  fi
}

wifi_menu() {
  local index radio current device
  while :; do
    radio=$(nmcli radio wifi 2>/dev/null)
    current=$(wifi_current_ssid)
    if [[ $radio == enabled ]]; then
      index=$(rofi_index 'Wi-Fi' "● Wi-Fi: on${current:+ ($current)}" '○ Turn Wi-Fi off' '○ Nearby networks' '○ Disconnect' '← Back') || return
      case $index in
        0) ;;
        1) nmcli radio wifi off ;;
        2) wifi_network_menu ;;
        3) device=$(wifi_device); [[ -n $device ]] && nmcli device disconnect "$device" ;;
        *) return ;;
      esac
    else
      index=$(rofi_index 'Wi-Fi' '○ Wi-Fi: off' '○ Turn Wi-Fi on' '← Back') || return
      case $index in 1) nmcli radio wifi on ;; *) return ;; esac
    fi
  done
}

bluetooth_powered() {
  bluetoothctl show 2>/dev/null | awk '/Powered:/ { print $2; exit }'
}

bluetooth_device_menu() {
  local record mac name state index
  local -a labels=() macs=()
  while read -r _ mac name; do
    [[ -n $mac ]] || continue
    macs+=("$mac")
    state=$(bluetoothctl info "$mac" 2>/dev/null | awk '/Connected:/ { print $2; exit }')
    if [[ $state == yes ]]; then labels+=("● $name"); else labels+=("○ $name"); fi
  done < <(bluetoothctl paired-devices)
  labels+=("← Back")
  index=$(rofi_index 'Bluetooth devices' "${labels[@]}") || return
  ((index < ${#macs[@]})) || return
  state=$(bluetoothctl info "${macs[index]}" 2>/dev/null | awk '/Connected:/ { print $2; exit }')
  if [[ $state == yes ]]; then bluetoothctl disconnect "${macs[index]}"; else bluetoothctl connect "${macs[index]}"; fi
}

bluetooth_menu() {
  local index powered
  while :; do
    powered=$(bluetooth_powered)
    if [[ $powered == yes ]]; then
      index=$(rofi_index 'Bluetooth' '● Bluetooth: on' '○ Turn Bluetooth off' '○ Paired devices' '← Back') || return
      case $index in 1) bluetoothctl power off ;; 2) bluetooth_device_menu ;; *) return ;; esac
    else
      index=$(rofi_index 'Bluetooth' '○ Bluetooth: off' '○ Turn Bluetooth on' '← Back') || return
      case $index in 1) bluetoothctl power on ;; *) return ;; esac
    fi
  done
}

brightness_percent() {
  brightnessctl -m 2>/dev/null | awk -F, 'NR == 1 { gsub(/%/, "", $5); print $5 }'
}

brightness_menu() {
  local index current
  while :; do
    current=$(brightness_percent)
    index=$(rofi_index 'Brightness' "● Current: ${current:-?}%" '○ Increase 5%' '○ Decrease 5%' '○ Set 25%' '○ Set 50%' '○ Set 75%' '○ Set 100%' '← Back') || return
    case $index in
      0) ;;
      1) brightnessctl set +5% ;;
      2) brightnessctl set 5%- ;;
      3) brightnessctl set 25% ;;
      4) brightnessctl set 50% ;;
      5) brightnessctl set 75% ;;
      6) brightnessctl set 100% ;;
      *) return ;;
    esac
  done
}

power_menu() {
  local index
  index=$(rofi_index 'Power' '○ Lock' '○ Suspend' '○ Reboot' '○ Power Off' '○ Logout' '← Back') || return
  case $index in
    0) loginctl lock-session ;;
    1) systemctl suspend ;;
    2) confirm 'Reboot?' && systemctl reboot ;;
    3) confirm 'Power off?' && systemctl poweroff ;;
    4) [[ -n ${XDG_SESSION_ID:-} ]] && loginctl terminate-session "$XDG_SESSION_ID" ;;
  esac
}

main_menu() {
  local index
  while :; do
    index=$(rofi_index 'System control' 'Audio' 'Wi-Fi' 'Bluetooth' 'Brightness' 'Power') || return
    case $index in
      0) audio_menu ;;
      1) wifi_menu ;;
      2) bluetooth_menu ;;
      3) brightness_menu ;;
      4) power_menu ;;
    esac
  done
}

main_menu
