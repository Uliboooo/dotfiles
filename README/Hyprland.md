# Hyprland Help

## Keybinds

S=Super(Meta)
A=Alt
C=Ctrl
SH=Shiht

### main controls

| binding | control |
| :---: | :---: |
| S + "D" | Open app launcher |
| S + "Q" | Close focused window |
| S + "T" | Open termianl(=kitty) |
| S + "M" | Exit Hyprland(=logout) |
| S + "E" | Open filer(=yazi on kitty) |
| S + "V" | Tpggle float |
| S + "F" | Toggle fullscreen |
| S + SH + "J" | toggle derection of split |

### Move focus

move focus with `S + {Arrow keys or HJKL}`

### Switch Workspaces

switch Workspaces with `S + number`

0 is 10.

This Hyprland configuration have tow special workspaces that can be opened from anywhere. for always-running applications such as chat apps.

- `MSG`: `S + "S"` (for chat)
- `SCR`: `S + "\"` (for temporary use)

### move window to a workspace

- move window to workspace with `S + SH + {number or "S" or "\"}`
- swap left window and right window in a workspace with `S + SH + {H or L}`

### Resize window

- `S + "R"`: enter resize mode, Resizable using HJKL
- `S + right click + mouse cursor`: Resizable using mouse cursor

### ScreenShots

take a ScreenShots with `hyprshot`.

| binding | control |
| :---: | :---: |
| PRINT | take a focused window |
| S + "P" | take a focused window |
| C + SH + "S" | take with region |
| S + PRINT | take a focused display |

### Command Palette

this configuration have some command palette features with rofi and my python scripts.

| binding | control |
| :---: | :---: |
| S + SH + "P" | utils palette |
| S + SH + "E" | lock, logout palette |
| S + SH + "V" | chipboard history |


### wallpapers controls

| binding | control |
| :---: | :---: |
| S + "W" | next wallpaper |
| S + SH + "W" | previous wallpaper |

### Audio and brightness control

support mainly meta keys(fn keys).

- `XF86AudioRaiseVolume`
- `XF86AudioLowerVolume`
- `XF86AudioMute`
- `XF86AudioMicMute`
- `XF86MonBrightnessUp`
- `XF86MonBrightnessDown`
- `XF86AudioNext`
- `XF86AudioPlay`
- `XF86AudioPrev`
- `XF86Favorites`: toggle play-pause

## Wallpapers

slidshow wallpapers when using home-manager of nix as user-systemd.

Internally, wallpaper rotation is handled by the `wlmstr` command together with `awww`, allowing navigation through wallpapers in a directory. Wallpapers are automatically rotated every 15 minutes at `00`, `15`, `30`, and `45` minutes past the hour.

As described above, you can also manually cycle wallpapers forward or backward using `Super + W`.

wlmstr helps

```
Stateful wallpaper slideshow CLI for awww

Usage: wlmstr <COMMAND>

Commands:
  next    go to next slide
  status  Get status. supports to output in JSON or debug format
  set     set config data
  help    Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version
```
