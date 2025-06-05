#!/bin/bash
ab_install() {
    if command -v brew >/dev/null 2>&1; then
        brew install "${1}" && return 0
    elif command -v apt >/dev/null 2>&1; then
        sudo apt install "${1}" -y && return 0
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install "${1}" -y && return 0
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S "${1}" --noconfirm && return 0
    else
        echo "sorry. don't support your os."
        return 1
    fi
}

ab_installs() {
for i in "$@"; do
    ab_install "${i}"
}
