#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

is_pkg_known() {
  local pkg="$1"
  dnf -q info "$pkg" >/dev/null 2>&1
}

pick_first_available() {
  local pkg
  for pkg in "$@"; do
    if is_pkg_known "$pkg"; then
      echo "$pkg"
      return 0
    fi
  done
  return 1
}

install_one() {
  local pkg="$1"
  if $SUDO dnf install -y "$pkg"; then
    return 0
  fi
  return 1
}

echo "Installing Fedora packages required by your Niri config..."

required_sets=(
  "waybar"
  "rofi"
  "kitty"
  "nautilus"
  "gnome-calendar"
  "pavucontrol"
  "blueman"
  "NetworkManager-tui"
  "brightnessctl"
  "playerctl"
  "wl-clipboard"
  "cliphist"
  "fcitx5"
  "flatpak"
  "gnome-keyring"
  "dbus-daemon"
  "xdg-desktop-portal"
  "xdg-desktop-portal-gtk"
  "xdg-desktop-portal-wlr"
  "SwayNotificationCenter swaynotificationcenter"
  "btm bottom"
  "swaylock swaylock-effects"
  "swayidle"
)

missing_pkgs=()
failed_pkgs=()

for set in "${required_sets[@]}"; do
  # shellcheck disable=SC2206
  candidates=($set)
  if selected="$(pick_first_available "${candidates[@]}")"; then
    echo "Installing: $selected"
    if ! install_one "$selected"; then
      failed_pkgs+=("$selected")
    fi
  else
    missing_pkgs+=("${candidates[0]}")
  fi
done

# tlp conflicts with tuned on many Fedora installs; skip automatically if tuned exists.
if rpm -q tuned >/dev/null 2>&1; then
  echo "Skipping tlp: tuned is installed (they conflict)."
  echo "If you want TLP, remove tuned first, then install tlp manually."
else
  if is_pkg_known tlp; then
    echo "Installing: tlp"
    if install_one tlp; then
      echo "Enabling TLP service..."
      $SUDO systemctl enable --now tlp.service || true
    else
      failed_pkgs+=("tlp")
    fi
  else
    missing_pkgs+=("tlp")
  fi
fi

echo "Trying optional packages (non-fatal if unavailable)..."
optional_sets=(
  "ghostty"
)

for set in "${optional_sets[@]}"; do
  # shellcheck disable=SC2206
  candidates=($set)
  if selected="$(pick_first_available "${candidates[@]}")"; then
    echo "Installing optional: $selected"
    install_one "$selected" || echo "WARN: Optional package install failed: $selected"
  else
    echo "WARN: Optional package unavailable: ${candidates[0]}"
  fi
done

AWWW_LOCAL_BUILD="$HOME/ghq/codeberg.org/LGFae/awww/target/release/awww-daemon"
if command -v awww-daemon >/dev/null 2>&1; then
  echo "awww-daemon already available: $(command -v awww-daemon)"
elif [[ -x "$AWWW_LOCAL_BUILD" ]]; then
  mkdir -p "$HOME/.local/bin"
  cp "$AWWW_LOCAL_BUILD" "$HOME/.local/bin/awww-daemon"
  echo "Installed local build to $HOME/.local/bin/awww-daemon"
  echo "Make sure ~/.local/bin is in PATH."
else
  echo "WARN: awww-daemon not found in PATH and local build was not found at:"
  echo "      $AWWW_LOCAL_BUILD"
fi

echo
if ((${#missing_pkgs[@]} > 0)); then
  echo "Not found in enabled repositories:"
  printf '  - %s\n' "${missing_pkgs[@]}"
fi
if ((${#failed_pkgs[@]} > 0)); then
  echo "Failed to install:"
  printf '  - %s\n' "${failed_pkgs[@]}"
fi
echo "Done. Re-login (or restart Niri session) to ensure all user services pick up changes."
