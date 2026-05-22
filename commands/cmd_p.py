#!/usr/bin/env python3

import os
import general_cmd_p

home = os.path.expanduser("~")
script = home + "/dotfiles/script/"
# kitty = home + "~/dotfiles/.config/kitty/"
slide_dev = home + "/Develop/linux_slide/"

cmds = {
    "󰸉 Toggle WP slideshow":   ["sh", script + "cycle_wallpaper.sh", "pse"],
    "󰔎 Toggle theme L-D":          ["ysh", script + "toggle_theme.ysh"],
    " Random WP":                 ["sh", script + "cycle_wallpaper.sh", "rnd"],
    "󰴰 Change to pub WP":               ["ysh", script + "safe_wallpaper.ysh"],
    " Show status of WP slide":   ["ysh", script + "status_of_slide.ysh"],
    "󱎐 Launch white in kitty":            ["kitty", "--config", home + "/dotfiles/.config/kitty/light.conf"],
    "󰹑 Screenshot active monitor":        ["hyprshot", "-m", "output", "-m", "active", "--freeze"],
    "󱂬 Screenshot active window":         ["hyprshot", "-m", "window", "-m", "active", "--freeze"],
    " Toggle visual effects":            ["ysh", script + "toggle_visual.ysh"],
    "󰑓 Reload Hyprland config":           ["hyprctl", "reload"],
}

general_cmd_p.pa(cmds)

