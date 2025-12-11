# My Dotfiles

**wip**

This repository contains my personal dotfiles for various tools and configurations.

The setup script will:

* Install necessary packages using your system's package manager (supports Homebrew, APT, DNF, and Pacman).
* Create symbolic links for the configuration files in your home directory.

## Included Configurations

This repository includes configurations for the following tools:

* **Shell:** Zsh, Starship
* **Editors:** Neovim, Zed, emacs
* **Terminal:** Ghostty, Alacritty, Wezterm
* **Other:** Git, Fastfetch, hyprland

## Notes

* The `setup.sh` script will attempt to install required packages. You may need to install some dependencies manually depending on your operating system.
* Review the `setup.sh` and `setup/links.sh` scripts to see exactly what will be installed and linked.
