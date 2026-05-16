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

  # ログインマネージャは必要に応じて変更
  services.greetd.enable = true;
  services.greetd.settings.default_session.command =
    "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd Hyprland";

  environment.systemPackages = with pkgs; [
    # Hyprland 周辺ユーティリティ
    waybar
    rofi-wayland
    hyprpaper
    hyprlock
    hypridle
    wl-clipboard
    swaynotificationcenter
    kitty
  ];
}
