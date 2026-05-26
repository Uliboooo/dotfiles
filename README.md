## Overview

![image](./README_Screenshots/2026-03-15-163050_hyprshot.jpg)

## includes config

| Tool | |
| :---: | :---: |
| Terminal | Kitty, Ghostty |
| Editor | Neovim, Vim|
| Shell | zsh |
| Launcher | rofi |
| VCS | git |
| DE/WM | Hyprland |
| Lock | Hypridle, Hyprlock |
| Bar | Waybar |
| Wallpaper | awww(swww), mpvpaper |
| Filer | yazi |
| Scripts | Bash, Python, YSH |

Catppuccin, and rose-pine are used mainly themes of my tools.
and many of these scripts are dependent on my personal environment, it might not work as-is in your environment...

## Requires of Hyprland

- hyprshot:   take screenshots
- hypridle:   auto start lock
- hyprlock:   lock screen
- hyprpicker: to use `freeze` option of hyprshot
- awww:       wallpapers manager
- systemd:    manage wallpapers slideshow
- waybar:     status bar
- btop,bluetui,nmtui: TUI tools for waybar

## NixOS + Flakes + Home Manager

This repo can manage both system and user settings with Nix, while keeping app configs as raw dotfiles.

### Structure (simple)

```text
~/dotfiles
├── flake.nix
├── hosts/
│   └── desktop/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── common.nix
│   ├── desktop.nix
│   └── thinkpad.nix
├── home/
│   └── alice.nix
├── nvim/
├── kitty/
├── hypr/
├── waybar/
└── ...
```

- `modules/desktop.nix`: system-wide desktop infrastructure (Hyprland, PipeWire, portal, polkit, etc.)
- `home/alice.nix`: personal apps and user config
- real app config files stay in this dotfiles repo as normal files/directories
- Home Manager deploys `~/.config/*` via `xdg.configFile` symlinks

### Rebuild commands

linux

```bash
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#desktop
```

macOS

```bash
cd ~/dotfiles
sudo darwin-rebuild switch --flake .#macbook
```

Update flake inputs first (optional):

```bash
cd ~/dotfiles
sudo nix flake update
sudo nixos-rebuild switch --flake .#desktop
```

### Migration from /etc/nixos

```bash
sudo cp /etc/nixos/hardware-configuration.nix ~/dotfiles/hosts/desktop/
```

Then move your old system settings into:
- `hosts/desktop/configuration.nix`
- `modules/common.nix`
- `modules/desktop.nix`

