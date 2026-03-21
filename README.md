# Hyprland Environment

This repository contains the dotfiles for a customized Hyprland desktop environment, designed to balance usability with visual customization.

## Overview

![image](./README_Screenshots/2026-03-15-163050_hyprshot.jpg)

The main components and applications that make up this environment are:

*   **Window Manager**: Hyprland
*   **Terminal**: Ghostty
*   **Application Launcher**: Fuzzel
*   **File Manager**: Nautilus
*   **Notification Daemon**: SwayNC
*   **Wallpaper Management Daemon**: swww
*   **Status Bar**: Waybar
*   **Screen Lock/Idle Management**: hyprlock / hypridle

## Features

### Wallpaper Cycling

Using `script/cycle_wallpaper.sh`, you can change wallpapers sequentially within a directory. A single shortcut key seamlessly switches to the next (or previous) wallpaper with animations.

### Utilization of Special Workspaces

In addition to regular workspaces (1-10), special named workspaces such as `Msg` (for messaging apps) and `ScrPad` (for scratchpad apps) are configured, allowing you to quickly call up or hide applications when needed.

## Keybindings

The `SUPER` key (e.g., Windows key) is used as the main modifier key.

| Keybinding          | Action                                 |
| :------------------ | :------------------------------------- |
| `SUPER + T`         | Launch terminal (Ghostty)              |
| `SUPER + D`         | Launch launcher (Fuzzel)               |
| `SUPER + E`         | Launch file manager (Nautilus)         |
| `SUPER + Q`         | Close active window                    |
| `SUPER + F`         | Toggle fullscreen                      |
| `SUPER + V`         | Toggle window float state              |
| `SUPER + C`         | Open/close notification center (SwayNC)|
| `SUPER + W`         | Change to next wallpaper               |
| `SUPER + SHIFT + W` | Change to previous wallpaper           |
| `SUPER + L`         | Lock screen (hyprlock)                 |
| `SUPER + S`         | Show/hide special workspace `Msg`      |
| `SUPER + \`         | Show/hide special workspace `ScrPad`   |
| `PRINT`             | Take a screenshot of the active window |

Other configurations include moving window focus (`SUPER + Arrow keys`), switching workspaces (`SUPER + 1-0`), moving windows, and resizing with mouse operations.

## Structure

*   `.config/hypr/`: Core Hyprland configuration files. Includes keybinding and startup process settings (`hyprland.conf`), as well as design configuration files.
*   `script/`: Custom shell scripts for wallpaper cycling, theme changes, and screen toggling.
*   `.config/waybar/`, `.config/fuzzel/`, `.config/ghostty/`, etc.: Configuration files for various integrated applications.
