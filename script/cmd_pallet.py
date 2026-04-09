#!/usr/bin/env python3

import subprocess
import os

home = os.path.expanduser("~")
script = home + "/dotfiles/script/"
# kitty = home + "~/dotfiles/.config/kitty/"
slide_dev = home + "/Develop/linux_slide/"

cmds = {
    "󰸉 Toggle slideshow of wallpapers":   ["sh", script + "cycle_wallpaper.sh", "pse"],
    "󰔎 Toggle light-dark theme":          ["sh", script + "toggle_theme.sh"],
    " Random wallpaper":                 ["sh", script + "cycle_wallpaper.sh", "rnd"],
    "󰴰 Change to pub wall":               ["sh", script + "safe_wallpaper.sh"],
    "Show status of wallpaper slide":   ["sh", script + "status_of_slide.sh"],
    "Launch slide in kitty":            ["kitty", "--config", home + "/dotfiles/.config/kitty/slide.conf", "--directory", slide_dev],
    "Launch white in kitty":            ["kitty", "--config", home + "/dotfiles/.config/kitty/light.conf"],
    "󰹑 Screenshot active monitor":        ["hyprshot", "-m", "output", "-m", "active", "--freeze"],
    "󱂬 Screenshot active window":         ["hyprshot", "-m", "window", "-m", "active", "--freeze"],
    "Toggle visual effects":            ["sh", script + "toggle_visual.sh"],
    "Reload Hyprland config":           ["hyprctl", "reload"],
}

res = "\n".join(cmds.keys())
cmd_res = subprocess.run(
    ["rofi", "-dmenu", "-p", "󰘳 "],
    input=res, text=True, capture_output=True
)

if cmd_res.returncode != 0:
    exit(0)

choice = cmds.get(cmd_res.stdout.strip())
if choice is None:
    print("not chosen")
else:
    subprocess.run(choice)

