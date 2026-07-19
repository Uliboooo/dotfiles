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

Option A (nix-darwin) and Option B (standalone Home Manager) are **mutually
exclusive** — pick one. Option A manages system settings too; Option B only
touches the user environment and needs no `sudo`.

#### Prerequisites

- **Apple Silicon only.** Nixpkgs 26.11 dropped `x86_64-darwin`, so an Intel Mac
  would need `nixpkgs` re-pinned to the `nixpkgs-26.05-darwin` branch.
- **The repo must live at `~/dotfiles`.** Home Manager symlinks `~/.config/*`
  out of that exact path (`dotfilesDir` in `home/common_user.nix`), so cloning
  elsewhere silently breaks every config link.
- The macOS username must be `seli`. To use a different one, change
  `users.users` + `system.primaryUser` in `hosts/macbook/configuration.nix` and
  `home-manager.users` in `flake.nix`, and rename `home/seli.nix`.

#### Step 1: Install Nix and clone

```bash
sh <(curl -L https://nixos.org/nix/install)
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
```

The upstream installer does **not** enable flakes, and this repo only provides
`experimental-features` *after* the first switch (Home Manager symlinks
`~/.config/nix` from `.config/nix/`). So the bootstrap below passes the flag
explicitly via `NIX_CONFIG`. Don't hand-create `~/.config/nix/nix.conf` — it
would then collide with the symlink Home Manager wants to create.

#### Option A: nix-darwin (system + user)

nix-darwin generates `/etc/bashrc` and `/etc/zshrc`, but it only moves an
existing file aside to `*.before-nix-darwin` when it recognizes the content.
The Nix installer has already appended its own block to both, so activation
aborts with *"Unexpected files in /etc"* until you move them yourself:

```bash
sudo mv /etc/bashrc{,.before-nix-darwin}
sudo mv /etc/zshrc{,.before-nix-darwin}
```

This is safe: nix-darwin regenerates both, and its `/etc/zshenv` exports
`environment.systemPath`, which includes `/nix/var/nix/profiles/default/bin` —
so Nix itself stays on `PATH`. Keep the current terminal open until the switch
succeeds, though: between the `mv` and the switch, nothing puts Nix on `PATH`
for a *newly opened* shell. If you get stranded there, recover with
`. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`. Then:

```bash
sudo NIX_CONFIG="experimental-features = nix-command flakes" \
  nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles#macbook
```

The same "unrecognized content" rule applies to `/etc/nix/nix.conf`, which is
why the bootstrap passes `NIX_CONFIG` instead of editing that file by hand.

After the first switch, flakes are enabled system-wide via `nix.settings`, so
subsequent updates are just:

```bash
sudo darwin-rebuild switch --flake ~/dotfiles#macbook
```

#### Option B: Standalone Home Manager (packages only)

```bash
NIX_CONFIG="experimental-features = nix-command flakes" \
  nix run home-manager/master -- switch --flake ~/dotfiles#seli@aarch64-darwin
```

Subsequent updates:

```bash
home-manager switch --flake ~/dotfiles#seli@aarch64-darwin
```

Unlike the NixOS/nix-darwin module paths, standalone Home Manager has no
`backupFileExtension` set, so it aborts if a file it manages already exists.
Add `-b hm-backup` to move such files aside instead.

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
sudo darwin-rebuild switch --flake ~/dotfiles#macbook
```

**macOS (standalone Home Manager)**
```bash
home-manager switch --flake ~/dotfiles#seli@aarch64-darwin
```

### Update Packages (Flake Inputs)
To update the underlying packages (nixpkgs, etc.) to their latest versions:
```bash
cd ~/dotfiles
nix flake update
# Then run the appropriate rebuild command above
```
