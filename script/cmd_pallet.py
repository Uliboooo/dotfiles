#!/usr/bin/env python3

import subprocess
import os

home = os.path.expanduser("~")
script = home + "/dotfiles/script/"

cmds = {
    "toggle slideshow of wallpapers":   ["sh", script + "cycle_wallpaper.sh", "pse"],
    "toggle light-dark":                ["sh", script + "toggle_theme.sh"],
    "random wallpaper":                 ["sh", script + "cycle_wallpaper.sh", "rnd"],
    "change to pub wall":               ["sh", script + "safe_wallpaper.sh"],
    "show status wallpapers slideshow": ["sh", script + "status_of_slide.sh"],
    "screenshot active monitor":        ["hyprshot", "-m", "output", "-m", "active", "--freeze"],
    "screenshot active window":         ["hyprshot", "-m", "window", "-m", "active", "--freeze"],
    "toggle visual":                    ["sh", script + "toggle_visual.sh"],
    "reload hyprconf":                  ["hyprctl", "reload"],
}

res = "\n".join(cmds.keys())
cmd_res = subprocess.run(
    ["fuzzel", "--dmenu", "--prompt=  "],
    input=res, text=True, capture_output=True
)

if cmd_res.returncode != 0:
    exit(0)

choice = cmds.get(cmd_res.stdout.strip())
if choice is None:
    print("not chosen")
else:
    subprocess.run(choice)

