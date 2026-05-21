#!/bin/bash
set -euo pipefail

cd "$HOME"

# ==============================================================================
# OS check
# ==============================================================================

OS_NAME=$(uname -s)
if [ "$OS_NAME" = "Darwin" ]; then
  echo "macOS is not yet supported."
  exit 1
fi

# ==============================================================================
# Package manager detection
# ==============================================================================

# detect_pkg_manager
#   Probes for a supported package manager in order of preference:
#   yay (Arch AUR) > pacman (Arch) > dnf (Fedora/RHEL) > apt-get (Debian/Ubuntu)
#
#   Outputs: one of "yay" | "pacman" | "dnf" | "apt", or "" if none found.
detect_pkg_manager() {
  if command -v yay >/dev/null 2>&1; then
    echo "yay"
  elif command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  elif command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  else
    echo ""
  fi
}

PKG_MANAGER=$(detect_pkg_manager)

if [[ -z "$PKG_MANAGER" ]]; then
  echo "Error: No supported package manager found (yay, pacman, dnf, apt)"
  exit 1
fi

echo "Detected package manager: ${PKG_MANAGER}"

# ==============================================================================
# Abstracted package manager functions
# ==============================================================================

# pkg_update
#   Runs a full system upgrade using the detected package manager.
#   No arguments.
pkg_update() {
  case "$PKG_MANAGER" in
    yay)    yay -Syu --noconfirm ;;           # -S sync, -y refresh DB, -u upgrade, --noconfirm skip prompts
    pacman) sudo pacman -Syu --noconfirm ;;   # same flags via pacman
    dnf)    sudo dnf update -y ;;             # -y assume yes
    apt)    sudo apt-get update -y ;;         # refresh package index
  esac
}

# pkg_install
#   Installs one or more packages using the detected package manager.
#
#   Arguments: $@ — list of package names to install
pkg_install() {
  local pkgs=("$@")
  case "$PKG_MANAGER" in
    yay)    yay -S --needed --noconfirm "${pkgs[@]}" ;;           # --needed skip already-installed
    pacman) sudo pacman -S --needed --noconfirm "${pkgs[@]}" ;;   # --needed skip already-installed
    dnf)    sudo dnf install -y "${pkgs[@]}" ;;                   # -y assume yes
    apt)    sudo apt-get install -y "${pkgs[@]}" ;;               # -y assume yes
  esac
}

# ==============================================================================
# Package lists per distro
# ==============================================================================

# Arch Linux / yay (includes AUR packages)
ARCH_PKGS=(
  bat biome blueman bluez bluez-utils brightnessctl btop chafa cliphist
  cmake code deja-dup difftastic eza fastfetch fcitx5 fcitx5-configtool
  fcitx5-hazkey-bin fd ffmpeg figlet fish flatpak fprintd rofi fzf gdm gemini-cli
  ghostty github-cli glow gnome hazkey-zenzai-vulkan helix htop hyprland hypridle
  hyprlock hyprpaper hyprpicker hyprshade hyprshot imagemagick inkscape kdenlive kitty
  lazygit less llvm neovim niri nodejs noto-fonts-cjk noto-fonts-emoji npm obs-studio
  obsidian pipewire ripgrep reflector sheldon stylua swaybg swaync tailscale tmux
  ttf-0xproto-nerd vim vulkan-radeon vlc waybar wget which wl-clipboard zip shfmt zsh
)

# Fedora / dnf
DNF_PKGS=(
  bat btop chafa cmake eza fastfetch fd-find ffmpeg figlet fish flatpak fzf
  git gh glow htop ImageMagick inkscape kdenlive kitty lazygit less
  neovim nodejs npm obs-studio pipewire ripgrep sheldon stylua swaync tailscale
  tmux vim vlc wl-clipboard wget which zip zsh shfmt
)

# Debian / Ubuntu / apt
APT_PKGS=(
  bat btop chafa cmake fd-find ffmpeg figlet fish flatpak fzf
  git gh htop imagemagick inkscape kdenlive kitty less
  neovim nodejs npm obs-studio pipewire ripgrep tmux vim
  vlc wl-clipboard wget zip zsh shfmt
)

# ==============================================================================
# Install packages
# ==============================================================================

echo "Installing packages with ${PKG_MANAGER}..."

pkg_update

case "$PKG_MANAGER" in
  yay | pacman) pkg_install "${ARCH_PKGS[@]}" ;;
  dnf)          pkg_install "${DNF_PKGS[@]}" ;;
  apt)          pkg_install "${APT_PKGS[@]}" ;;
esac

echo "Package installation complete."

# ==============================================================================
# Link configs to ~/.config
# ==============================================================================

DOTFILES_DIR="$HOME/dotfiles"

configs=(
  "fastfetch" "fish" "fontconfig" "fuzzel" "ghostty" "git"
  "helix" "hypr" "hypr-presto" "karukan-im" "kitty" "niri" "nwg-drawer"
  "nvim" "rofi" "sheldon" "stylua" "swaync" "systemd"
  "voime" "waybar" "vim" "xdg-desktop-portal" "yazi" "zsh-abbr"
)

mkdir -p "$HOME/.config"

echo "Linking config files..."

for conf in "${configs[@]}"; do
  config_path="$HOME/.config/${conf}"
  target_path="${DOTFILES_DIR}/.config/${conf}"

  if [[ ! -e "${target_path}" && ! -L "${target_path}" ]]; then
    echo "Skipping (not found in dotfiles): ${conf}"
    continue
  fi

  if [[ -e "${config_path}" || -L "${config_path}" ]]; then
    rm -rf "${config_path}"
  fi

  ln -fs "${target_path}" "${config_path}"   # -f force overwrite, -s symbolic link
  echo "Linked: ${conf}"
done

ln -fs "${DOTFILES_DIR}/.zshrc" "$HOME/.zshrc"   # -f force overwrite, -s symbolic link
echo "Linked: .zshrc"

# ==============================================================================
# Set default shell to zsh
# ==============================================================================

echo "Setting default shell to zsh..."

ZSH_PATH=$(command -v zsh 2>/dev/null || echo "")

if [[ -z "$ZSH_PATH" ]]; then
  echo "Warning: zsh not found, skipping shell change."
elif [[ "$SHELL" == "$ZSH_PATH" ]]; then
  echo "Default shell is already zsh."
else
  if chsh -s "$ZSH_PATH"; then   # -s set login shell to the given path
    echo "Default shell changed to zsh. Please log out and log back in to apply."
  else
    echo "Warning: chsh failed. You may need to run manually: chsh -s ${ZSH_PATH}"
  fi
fi

# ==============================================================================
# Enable systemd user services (systemd-based distros only)
# ==============================================================================

if command -v systemctl >/dev/null 2>&1; then
  echo "Enabling systemd user services..."
  systemctl --user enable --now ssh-agent 2>/dev/null || echo "Warning: ssh-agent service not found, skipping."             # --user operate on user session, --now also start immediately
  systemctl --user enable --now cycle_wallpaper.service 2>/dev/null || echo "Warning: cycle_wallpaper.service not found, skipping."
  systemctl --user enable --now cycle_wallpaper.timer 2>/dev/null || echo "Warning: cycle_wallpaper.timer not found, skipping."
fi

echo "Setup complete!"
