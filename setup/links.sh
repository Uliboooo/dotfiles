#! /bin/bash

link_or_ovr() {
  local conf_name="${1:?Error: Config name is required}"

  local base_path="${HOME}/.config"
  local dotfiles_path="${HOME}/dotfiles/.config"
  local conf_path="${base_path}/${conf_name}"
  local target_path="${dotfiles_path}/${conf_name}"

  if [[ ! -d "${base_path}" ]]; then
    mkdir -p "${base_path}"
  fi

  if [[ -e "${conf_path}" || -L "${conf_path}" ]]; then
    rm -rf "${conf_path}"
  fi

  ln -fs "${target_path}" "${conf_path}"

  echo "Linked: ${conf_name} -> ${conf_path}"
}

config_path=("bottom" "fastfetch" "fuzzel" "ghostty" "git" "helix" "hypr" "hypr-presto" "niri" "nvim" "starship.toml" "stylua" "swaync" "systemd" "voime" "waybar" "xdg-desktop-portal")

for nm in "${conf_path[@]}"; do
  link_or_ovr "${nm}"
done

