#!/usr/bin/env python3

import subprocess

def pa(cmds: dict[str,list[str]]):
    res = "\n".join(cmds.keys())
    cmd_res = subprocess.run(
        ["rofi", "-dmenu", "-i", "-p", "󰘳 "],
        input=res, text=True, capture_output=True
    )

    if cmd_res.returncode != 0:
        exit(0)

    choice = cmds.get(cmd_res.stdout.strip())
    if choice is None:
        print("not chosen")
    else:
        subprocess.run(choice)

