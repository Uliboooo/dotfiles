#!/usr/bin/env python3

import os
import general_cmd_p

home = os.path.expanduser("~")
script = home + "/dotfiles/script/"
slide_dev = home + "/Develop/linux_slide/"

cmds = {
    "󰗽 Logout": ["hyprctl", "dispatch", "exit"],
    "󰜉 Reboot": ["reboot"],
    " Lock":   ["hyprlock"],
    "󰜺 Cancel": ["exit"],
}

general_cmd_p.pa(cmds)
