#!/bin/bash
set -euo pipefail

cd "$HOME"

OS_NAME=$(uname -s)
if [ "$OS_NAME" = "Darwin" ]; then
  echo "macOS is not yet supported."
  exit 1
fi

if ! command -v yay >/dev/null 2>&1; then
  echo "yay doesn't exist, please install yay"
  exit 1
fi

echo "installing favo pkgs..."

yay -Syu bat biome blueman bluez bluez-utils brightnessctl btop chafa cliphist \
  cmake code deja-dup difftastic eza fastfetch fcitx5 fcitx5-configtool \
  fcitx5-hazkey-bin fd ffmpeg figlet fish flatpak fprintd fuzzel fzf gdm gemini-cli \
  ghostty github-cli glow gnome hazkey-zenzai-vulkan helix htop hyprland hypridle \
  hyprlock hyprpaper hyprpicker hyprshade hyprshot imagemagick inkscape kdenlive kitty \
  lazygit less llvm neovim niri nodejs noto-fonts-cjk noto-fonts-emoji npm obs-studio \
  obsidian pipewire ripgrep reflector starship stylua swaybg swaync tailscale tmux \
  ttf-0xproto-nerd vim vulkan-radeon vlc waybar wget which wl-clipboard zip shfmt zsh

configs=(
  "fastfetch" "fish" "fontconfig" "fuzzel" "ghostty" "git"
  "helix" "hypr" "hypr-presto" "niri" "nvim" "stylua"
  "swaync" "systemd" "voime" "waybar" "vim"
)

mkdir -p "$HOME/.config"

for conf in "${configs[@]}"; do
  config_path="$HOME/.config/${conf}"
  target_path="$HOME/dotfiles/.config/${conf}"

  if [[ -e "${config_path}" || -L "${config_path}" ]]; then
    rm -rf "${config_path}"
  fi

  ln -fs "${target_path}" "${config_path}"
j  echo "Linked: ${conf}"
done

ln -fs "$HOME/dotfiles/.zshrc" "$HOME/.zshrc"

cd "$HOME"

systemctl --user enable --now ssh-agent
systemctl --user enable --now cycle_wallpaper.service
systemctl --user enable --now cycle_wallpaper.timer

if chsh -s "$(which zsh)"; then
  echo "please logout and login to reload"
else
  echo "Warning: chsh failed"
fi
