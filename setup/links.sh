#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

link_or_ovr() {
  local conf_name="${1:?Error: Config name is required}"

  local base_path="${HOME}/.config"
  local target_path="${DOTFILES_DIR}/.config/${conf_name}"
  local conf_path="${base_path}/${conf_name}"

  if [[ ! -d "${base_path}" ]]; then
    mkdir -p "${base_path}"
  fi

  if [[ ! -e "${target_path}" && ! -L "${target_path}" ]]; then
    echo "Skipping (not found in dotfiles): ${conf_name}"
    return
  fi

  if [[ -e "${conf_path}" || -L "${conf_path}" ]]; then
    rm -rf "${conf_path}"
  fi

  ln -fs "${target_path}" "${conf_path}"

  echo "Linked: ${conf_name} -> ${conf_path}"
}

config_names=(
  "fastfetch" "fish" "fontconfig" "fuzzel" "ghostty" "git"
  "helix" "hypr" "hypr-presto" "karukan-im" "kitty" "niri" "nwg-drawer"
  "nvim" "rofi" "sheldon" "stylua" "swaync" "systemd"
  "voime" "waybar" "vim" "xdg-desktop-portal" "yazi" "zsh-abbr"
)

for nm in "${config_names[@]}"; do
  link_or_ovr "${nm}"
done

ln -fs "${DOTFILES_DIR}/.zshrc" "$HOME/.zshrc"
echo "Linked: .zshrc -> $HOME/.zshrc"
