{ pkgs, ... }:
{
  # ===== デスクトップ基盤 (システム全体) =====
  programs.hyprland.enable = true;

  # PipeWire + rtkit
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Wayland portal (Hyprland + GTK)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # polkit
  security.polkit.enable = true;
  # gnome-keyring を NixOS サービスとして有効化
  services.gnome.gnome-keyring.enable = true;
  # ログイン時に keyring を PAM 連携で解錠
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  # GDM (GUI ログイン) を使う
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "hyprland";
  services.greetd.enable = false;

  # 省電力管理 (TLP)
  services.tlp.enable = true;
  # TLP と競合しやすいため無効化
  services.power-profiles-daemon.enable = false;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  services.flatpak = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Hyprland 周辺ユーティリティ
    awww
    flatpak
    waybar
    rofi
    hyprpaper
    hyprlock
    hypridle
    hyprpicker
    hyprshot
    wl-clipboard
    swaynotificationcenter
    kitty
    cliphist
  ];
}
