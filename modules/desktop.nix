{ pkgs, ... }:
{
  # ===== desktop base (entire system) =====
  programs.hyprland.enable = true;
  programs.niri.enable = true;
  # Installs hyprlock *and* creates /etc/pam.d/hyprlock. Without the PAM
  # service, hyprlock falls through to /etc/pam.d/other (pam_deny) and the
  # password fallback can never succeed.
  programs.hyprlock.enable = true;
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
  # An authentication agent is required for any action whose polkit default is
  # auth_self / auth_admin (fprintd enroll, udisks mounts, ...). Without one the
  # request is denied outright with no prompt. GDM only supplies an agent to its
  # own greeter, so a bare niri/Hyprland session has none.
  systemd.packages = [ pkgs.hyprpolkitagent ];
  systemd.user.services.hyprpolkitagent.wantedBy = [ "graphical-session.target" ];
  # enable gnome-keyring as NixOS services
  services.gnome.gnome-keyring.enable = true;
  # unlock keyring by PAM relation when login
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  services.upower.enable = true;

  # GDM
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "hyprland";
  services.greetd.enable = false;

  services.keyd = {
    enable = true;

    keyboards.default.settings.main = {
      pageup = "noop";
      pagedown = "noop";

      assistant = "rightmeta";

      # Delete は単押しでは何も送らない（実質無効化）。300ms 長押しで coffee
      # (evdev 152 = KEY_SCREENLOCK) を送り、コンポジタ側でロックする
      # （hypr/config/binds.lua と niri/config.kdl の XF86ScreenSaver）。
      # evdev rules は必ず inet(evdev) を混ぜるので、この keycode は us 配列でも
      # XF86ScreenSaver という keysym を持つ = Hyprland でも niri でも拾える。
      # 長押し時間はここで調整する。
      delete = "timeout(noop, 300, coffee)";
    };
  };

  # Virtualization (libvirt + virt-manager + TPM2.0)
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;

  # tlp
  # services.tlp.enable = true;
  services.tlp = {
    enable = true;

    settings = {
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";
    };
  };
  services.power-profiles-daemon.enable = false;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Fonts: JP glyphs for CJK on lang-less pages, Monaspace Radon for Latin monospace
  fonts = {
    packages = with pkgs; [
      monaspace
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
    ];
    fontconfig.defaultFonts = {
      sansSerif = [
        "Noto Sans"
        "Noto Sans CJK JP"
      ];
      serif = [
        "Noto Serif"
        "Noto Serif CJK JP"
      ];
      monospace = [
        "Monaspace Radon"
        "Noto Sans Mono CJK JP"
        "Symbols Nerd Font Mono"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  environment.systemPackages = with pkgs; [
    awww
    waybar
    rofi
    hyprpaper
    hypridle
    hyprpolkitagent
    hyprpicker
    hyprshot
    wl-clipboard
    swaynotificationcenter
    kitty
    cliphist
    swtpm
    udiskie
    usbutils
  ];
}
