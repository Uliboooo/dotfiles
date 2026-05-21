## Overview

![image](./README_Screenshots/2026-03-15-163050_hyprshot.jpg)

## includes config

| Tool | |
| :---: | :---: |
| Terminal | Kitty, Ghostty |
| Editor | Neovim, Vim|
| Shell | YSH, zsh, fish |
| Launcher | rofi, fuzzel |
| VCS | git |
| DE/WM | Hyprland |
| Lock | Hypridle, Hyprlock |
| Bar | Waybar |
| Wallpaper | awww(swww) |
| Filer | yazi |
| Scripts | YSH, Bash, Python |

Catppuccin, and rose-pine are used mainly themes of my tools.
and many of these scripts are dependent on my personal environment, it might not work as-is in your environment...

## YSH

YSH config now lives in `~/.config/oils/yshrc` (tracked in the repo as `.config/oils/yshrc`).

The current setup keeps the existing zsh login-shell flow intact, but the shared shell environment now also has a first-class YSH config so it can be tried incrementally.

## Requires of Hyprland

- hyprshot:   take screenshots
- hypridle:   auto start lock
- hyprlock:   lock screen
- hyprpicker: to use freeze option of hyprshot
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

```bash
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#desktop
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
