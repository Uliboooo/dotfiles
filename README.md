# My Dotfiles

**wip**

This repository contains my personal dotfiles for various tools and configurations.

## Installation

To install these dotfiles, clone the repository and run the `setup.sh` script:

```bash
git clone https://github.com/your-username/dotfiles.git
cd dotfiles
./setup.sh
```

The setup script will:

* Install necessary packages using your system's package manager (supports Homebrew, APT, DNF, and Pacman).
* Create symbolic links for the configuration files in your home directory.

## Included Configurations

This repository includes configurations for the following tools:

* **Shell:** Zsh, Starship
* **Editors:** Neovim, Vim, Zed
* **Terminal:** Alacritty, Wezterm
* **Other:** Git, Fastfetch, Nano

## Notes

* The `setup.sh` script will attempt to install required packages. You may need to install some dependencies manually depending on your operating system.
* Review the `setup.sh` and `setup/links.sh` scripts to see exactly what will be installed and linked.
