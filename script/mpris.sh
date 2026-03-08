#!/usr/bin/env bash

# mpris.sh <status|title|artist|progress|art>

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hyprlock"
mkdir -p "$CACHE_DIR"

_player() {
    playerctl --list-all 2>/dev/null | head -1
}

_is_active() {
    local player="$1"
    local status
    status=$(playerctl --player="$player" status 2>/dev/null)
    [ "$status" = "Playing" ] || [ "$status" = "Paused" ]
}

mpris_status() {
    local player
    player=$(_player)
    [ -z "$player" ] && return

    local status
    status=$(playerctl --player="$player" status 2>/dev/null)
    case "$status" in
        Playing)
            local icon
            case "$player" in
                *spotify*)          icon="" ;;
                *mpd*|*mopidy*)    icon="󰎆" ;;
                *firefox*|*chrom*) icon="󰈹" ;;
                *)                  icon="󰝚" ;;
            esac
            echo "$icon  Now Playing"
            ;;
        Paused)
            echo "󰏤  Paused"
            ;;
    esac
}

mpris_title() {
    local player
    player=$(_player)
    [ -z "$player" ] && return
    _is_active "$player" || return

    local title
    title=$(playerctl --player="$player" metadata title 2>/dev/null)
    [ -z "$title" ] && return

    if [ ${#title} -gt 28 ]; then
        echo "${title:0:26}…"
    else
        echo "$title"
    fi
}

mpris_artist() {
    local player
    player=$(_player)
    [ -z "$player" ] && return
    _is_active "$player" || return

    local artist
    artist=$(playerctl --player="$player" metadata artist 2>/dev/null)
    [ -z "$artist" ] && return

    if [ ${#artist} -gt 32 ]; then
        echo "${artist:0:30}…"
    else
        echo "$artist"
    fi
}

mpris_progress() {
    local player
    player=$(_player)
    [ -z "$player" ] && return
    _is_active "$player" || return

    local pos length
    pos=$(playerctl --player="$player" position 2>/dev/null | cut -d. -f1)
    length=$(playerctl --player="$player" metadata mpris:length 2>/dev/null)
    [ -z "$pos" ] || [ -z "$length" ] && return

    local len_sec=$((length / 1000000))
    [ $len_sec -le 0 ] && return

    local pos_min=$((pos / 60))
    local pos_sec=$((pos % 60))
    local len_min=$((len_sec / 60))
    local len_sec_r=$((len_sec % 60))

    local filled=$((pos * 16 / len_sec))
    [ $filled -gt 16 ] && filled=16

    local bar=""
    for i in $(seq 1 $filled);           do bar="${bar}▰"; done
    for i in $(seq $((filled+1)) 16);    do bar="${bar}▱"; done

    printf "%d:%02d  %s  %d:%02d\n" $pos_min $pos_sec "$bar" $len_min $len_sec_r
}

mpris_art() {
    local player
    player=$(_player)
    [ -z "$player" ] && return
    _is_active "$player" || return

    local url
    url=$(playerctl --player="$player" metadata mpris:artUrl 2>/dev/null)
    [ -z "$url" ] && return

    if [[ "$url" == file://* ]]; then
        echo "${url#file://}"
    else
        local trackid
        trackid=$(playerctl --player="$player" metadata mpris:trackid 2>/dev/null | tr -dc 'a-zA-Z0-9' | tail -c 40)
        local cached="$CACHE_DIR/art_${trackid}.jpg"
        if [ ! -f "$cached" ]; then
            rm -f "$CACHE_DIR"/art_*.jpg 2>/dev/null
            curl -sL "$url" -o "$cached" 2>/dev/null
        fi
        [ -f "$cached" ] && echo "$cached"
    fi
}

# エントリポイント
case "$1" in
    status)   mpris_status   ;;
    title)    mpris_title    ;;
    artist)   mpris_artist   ;;
    progress) mpris_progress ;;
    art)      mpris_art      ;;
    *)
        echo "Usage: $0 <status|title|artist|progress|art>" >&2
        exit 1
        ;;
esac
