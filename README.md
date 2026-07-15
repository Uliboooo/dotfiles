## Overview

![image](./README/jul14.png)

view [Hyprland manual](./README/Hyprland.md), view [Uncoated Paper design manual](./README/PaperDesign.md)

## includes config

| Tool | |
| :---: | :---: |
| Terminal | Kitty |
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
home-manager switch --flake .#seli
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

### 3. macOS

Two options. Use nix-darwin if you want system settings managed by Nix too;
use standalone Home Manager if you only want Nix as a package manager.

Both assume the macOS username is `seli` and an Apple Silicon machine
(`aarch64-darwin`). For a different username, change `hosts/macbook/configuration.nix`
and the `home-manager.users` attribute in `flake.nix`. For an Intel Mac, set
`darwinSystem = "x86_64-darwin"` in `flake.nix`.

#### Option A: nix-darwin (system + user)

```bash
sh <(curl -L https://nixos.org/nix/install)
cd ~/dotfiles
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#macbook
```

Subsequent updates:

```bash
sudo darwin-rebuild switch --flake .#macbook
```

#### Option B: Standalone Home Manager (packages only)

No `sudo`, no system settings touched — just the user environment.

```bash
sh <(curl -L https://nixos.org/nix/install)
cd ~/dotfiles
nix run home-manager/master -- switch --flake .#seli@aarch64-darwin
```

Subsequent updates:

```bash
home-manager switch --flake .#seli@aarch64-darwin
```

## Structure (simple)

```text
~/dotfiles
├── flake.nix
├── hosts/
│   ├── desktop/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── macbook/
│       └── configuration.nix
├── modules/
│   ├── common.nix
│   ├── desktop.nix
│   └── thinkpad.nix
├── home/
│   ├── seli.nix
│   ├── common_user.nix
│   └── ...
├── nvim/
├── kitty/
├── hypr/
├── waybar/
└── ...
```

- `modules/desktop.nix`: system-wide desktop infrastructure (Hyprland, PipeWire, portal, polkit, etc.)
- `home/seli.nix`: personal apps and user config
- real app config files stay in this dotfiles repo as normal files/directories
- Home Manager deploys `~/.config/*` via `xdg.configFile` symlinks

## Maintenance & Updates

After making changes to your configuration files, use the following commands to apply them.

### Rebuild (Apply Changes)

**Standalone Linux (Debian, Ubuntu, etc.)**
```bash
cd ~/dotfiles
home-manager switch --flake .#seli
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

**macOS (standalone Home Manager)**
```bash
cd ~/dotfiles
home-manager switch --flake .#seli@aarch64-darwin
```

### Update Packages (Flake Inputs)
To update the underlying packages (nixpkgs, etc.) to their latest versions:
```bash
cd ~/dotfiles
nix flake update
# Then run the appropriate rebuild command above
```
