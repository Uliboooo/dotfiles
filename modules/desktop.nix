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

  # GDM (GUI ログイン) を使う
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "hyprland";
  services.greetd.enable = false;

  environment.systemPackages = with pkgs; [
    # Hyprland 周辺ユーティリティ
    waybar
    rofi
    hyprpaper
    hyprlock
    hypridle
    wl-clipboard
    swaynotificationcenter
    kitty
  ];
}
