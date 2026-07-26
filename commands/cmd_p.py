#!/usr/bin/env python3

import os
import sys

# niri の spawn-sh / hyprland の exec_cmd は cwd がこのディレクトリにならないため、
# 隣の general_cmd_p.py を import できるよう自分の場所を sys.path に足す。
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import general_cmd_p

home = os.path.expanduser("~")
script = home + "/dotfiles/script/"
# kitty = home + "~/dotfiles/.config/kitty/"
slide_dev = home + "/Develop/linux_slide/"

cmds = {
    "󰸉 Toggle WP slideshow":              ["bash", script + "wallpaper_toggle.sh", "pse"],
    "󰔎 Toggle theme L-D":                 ["bash", script + "toggle_theme.sh"],
    " Random WP":                        ["wlmstr", "next", "rnd"],
    "󰴰 Change to pub WP":                 ["bash", script + "safe_wallpaper.sh"],
    " Show status of WP slide":          ["bash", script + "status_of_slide.sh"],
    "󱎐 Launch white in kitty":            ["kitty", "--config", home + "/dotfiles/.config/kitty/light.conf"],
    "󰹑 Screenshot active monitor":        ["hyprshot", "-m", "output", "-m", "active", "--freeze"],
    "󱂬 Screenshot active window":         ["hyprshot", "-m", "window", "-m", "active", "--freeze"],
    "󰑓 Reload Hyprland config":           ["hyprctl", "reload"],
}

general_cmd_p.pa(cmds)
