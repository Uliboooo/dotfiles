#!/usr/bin/env python3

import os
import subprocess
import sys

def color(text, code):
    return f"\033[{code}m{text}\033[0m"

def is_git_repo(path):
    for p in os.scandir(path):
        if p.name ==  ".git":
            return True
    return False

def get_git_status(path):
    result = subprocess.run(
            ["git", "status"],
            cwd=path,
            capture_output=True,
            text=True
            )
    return result.stdout

def is_clean_git_repo(status):
    return "working tree clean" in status

def parse_git_repo(status):
    str_status = str(status)

    # 0 => other
    # 1 => staged_added
    # 2 => unstage
    # 3 => untracked
    mode = 0

    d: dict[str, int] = {
            "staged_added": 0,
            "unstage": 0,
            "untracked": 0,
        }

    for l in str_status.splitlines():
        if "Changes to be committed:" in l:
            mode = 1
        elif "Changes not staged for commit:" in l:
            mode = 2
        elif "Untracked files:" in l:
            mode = 3
        elif mode == 1:
            d["staged_added"] += 1
        elif mode == 2:
            d["unstage"] += 1
        elif mode == 3:
            d["untracked"] += 1

    return d

def fmt_git_info(d: dict[str, int]):
    staged_cont = f"Changes to be committed: {d["staged_added"]}"
    unstaged_cont = f"Changes not staged for commit: {d["unstage"]}"
    untracked_cont = f"Untracked files: {d["untracked"]}"

    return f"  {color(staged_cont, 36)}\n  {color(unstaged_cont, 31)}\n  {color(untracked_cont, 31)}"

def iter_git_repos(path, is_list_mode):
    for entry in os.scandir(path):
        if os.path.isdir(entry) and is_git_repo(entry):
            status = get_git_status(entry)
            if is_list_mode:
                is_clean_git_status = is_clean_git_repo(status)
                if is_clean_git_status:
                    print(color(f"\n{entry.name} is cleaned, nothing todo", 32))
                else:
                    print(color(f"\n{entry.name} is have diff", 33))
                    d = parse_git_repo(status)
                    print(f"{fmt_git_info(d)}")
            else:
                print(color(f"{"-" * 4} {entry.name} {"-" * 24}", 32) + "\n")
                print(status)

def resolve_root_path():
    if len(sys.argv) < 2:
        return os.getcwd()
    else:
        return sys.argv[1]

def is_list_from_args():
    try:
        return sys.argv[2] in ("--list", "-l")
    except IndexError:
        return False

path= resolve_root_path()
is_list_mode = is_list_from_args()

iter_git_repos(path, is_list_mode)
