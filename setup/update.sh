#!/bin/bash
if command -v brew >/dev/null 2>&1; then
    brew update && brew upgrade -y
elif command -v apt >/dev/null 2>&1; then
    sudo apt update && apt upgrade -y
elif command -v dnf >dev/null 2>&1; then
    sudo dnf check-update && dnf update -y
elif command -v pacman >dev/null 2>&1; then
    sudo pacman -Syyu
else
    echo "sorry. don't support your os."
fi