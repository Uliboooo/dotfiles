## Overview

![image](./README/images/hl.png)

view [Hyprlnad manual](./README/Hyprland.md)
view [Emacs quick start](./README/Emacs.md)

## includes config

| Tool | |
| :---: | :---: |
| Terminal | Kitty(Linux), Ghostty(mac) |
| Editor | Neovim |
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

## Installation & Setup

This repository supports three main setup methods:
1. **NixOS** (Full system + user management)
2. **macOS** (System + user management via nix-darwin)
3. **Standalone Home Manager** (User management on generic Linux distros like Debian/Ubuntu)

### 1. Standalone Home Manager (Generic Linux)

Use this if you are on Debian, Ubuntu, Arch, etc., and only want to use Nix for your user environment.

#### Step 1: Install Nix

Install Nix with the official installer:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

#### Step 2: Enable Flakes

Ensure Flakes and Nix-command are enabled by adding this to `~/.config/nix/nix.conf` (or `/etc/nix/nix.conf`):

```text
experimental-features = nix-command flakes
```

#### Step 3: Clone & Deploy

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
nix run home-manager/master -- init --flake .#seli
nix run home-manager/master -- switch --flake .#seli
```
Subsequent updates:

```bash
home-manager switch --flake .#lilan
```

### 2. NixOS

#### Initial Setup
Clone this repo to `~/dotfiles`, then link your hardware configuration:
```bash
sudo cp /etc/nixos/hardware-configuration.nix ~/dotfiles/hosts/desktop/
```

#### Apply Configuration
```bash
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#desktop
```

### 3. macOS (nix-darwin)

#### Step 1: Install nix-darwin
Follow instructions at [nix-community/nix-darwin](https://github.com/LnL7/nix-darwin).

#### Step 2: Apply Configuration
```bash
cd ~/dotfiles
darwin-rebuild switch --flake .#macbook
```

## Structure (simple)

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
│   ├── lilan.nix
│   ├── common_user.nix
│   └── ...
├── nvim/
├── kitty/
├── hypr/
├── waybar/
└── ...
```

- `modules/desktop.nix`: system-wide desktop infrastructure (Hyprland, PipeWire, portal, polkit, etc.)
- `home/lilan.nix`: personal apps and user config
- real app config files stay in this dotfiles repo as normal files/directories
- Home Manager deploys `~/.config/*` via `xdg.configFile` symlinks

## Maintenance & Updates

After making changes to your configuration files, use the following commands to apply them.

### Rebuild (Apply Changes)

**Standalone Linux (Debian, Ubuntu, etc.)**
```bash
cd ~/dotfiles
home-manager switch --flake .#lilan
```

**NixOS**
```bash
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#desktop
```

**macOS (nix-darwin)**
```bash
cd ~/dotfiles
sudo darwin-rebuild switch --flake .#macbook
```

### Update Packages (Flake Inputs)
To update the underlying packages (nixpkgs, etc.) to their latest versions:
```bash
cd ~/dotfiles
nix flake update
# Then run the appropriate rebuild command above
```
