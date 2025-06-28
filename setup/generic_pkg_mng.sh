#!/bin/sh

install() {
  if command -v apt >/dev/null; then
    sudo apt update && sudo apt install $1
    return $?
  elif command -v dnf >/dev/null; then
    sudo dnf upgrade && sudo dnf install $1
    return $?
  elif command -v pacman >/dev/null; then
    sudo pacman -Syu && sudo pacman -S $1
    return $?
  elif command -v brew >/dev/null; then
    brew update && brew install $1
    return $?
  else
    echo "unknown"
    return 1
  fi
}

update() {
  if command -v apt >/dev/null; then
    sudo apt update && sudo apt upgrade
    return $?
  elif command -v dnf >/dev/null; then
    sudo dnf upgrade
    return $?
  elif command -v pacman >/dev/null; then
    sudo pacman -Syu
    return $?
  elif command -v brew >/dev/null; then
    brew update && brew upgrade
    return $?
  else
    echo "unknown"
    return 1
  fi

}
