#!/bin/bash

OS_NAME=$(uname -s)

if [ "$OS_NAME" = "Darwin" ]; then
  echo "macOS is not yet supported."
  exit 1
else
  echo "installing favo pkgs..."
  cd $HOME

  if command -v yay >/dev/null 2>&1; then
    echo "yay exists, skip"
  else
    # set up yay
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
  fi

  cd $HOME

  yay -Syu bat biome blueman bluez bluez-utils brightnessctl btop chafa cliphist \
    cmake code deja-dup difftastic eza fastfetch fcitc5 fcitx5-configtool \
    fcitx5-hazkey-bin fd ffmpeg figlet fish flatpak fprintd fuzzel fzf gdm gemini-cli \
    ghostty github-cli glow gnome hazkey-zenzai-vulkan helix htop hyprland hypridle \
    hyprlock hyprpaper hyprpicker hyprshade hyprshot imagemagick inkscape kdenlive kitty \
    lazygit less llvm neovim niri nodejs noto-fonts-cjk noto-fonts-emoji npm obs-studio \
    obsidian pipewire ripgrep reflector starship stylua swaybg swaync tailscale tmux \
    ttf-0xproto-nerd vim vulkan-radeon vlc waybar wget which wl-clipboard zip shfmt

  # set up symbolic links
  configs=("fastfetch" "fish" "fontconfig" "fuzzel" "ghostty" "git" "helix" "hypr" "hypr-presto" "niri" "nvim" "stylua" "swaync" "voime" "waybar")

  for conf in "${configs[@]}"; do
    config_path="$HOME/.config/${conf}"
    target_path="$HOME/dotfiles/.config/${conf}"

    # 1. 既存のファイル/ディレクトリ/リンクを削除
    # -e はファイルとディレクトリ両方に、-L はリンクに対応します
    if [[ -e "${config_path}" || -L "${config_path}" ]]; then
      rm -rf "${config_path}"
    fi

    # 2. 親ディレクトリが存在することを確認（念のため）
    mkdir -p "$HOME/.config"

    # 3. シンボリックリンクの作成
    ln -fs "${target_path}" "${config_path}"

    echo "Linked: ${conf}"
  done

  cd $HOME
  chsh -s $(which fish) && echo "please logout and login to reload"
fi
