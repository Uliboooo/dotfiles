{ pkgs, ... }:
{
  # ===== desktop base (entire system) =====
  programs.hyprland.enable = true;
  programs.niri.enable = true;
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

    # Firefox resolves a quoted "system-ui" (used by chatgpt.com and claude.ai)
    # through its internal system-font path, which bypasses the sans-serif
    # alias above and lands on the KR face for Han characters. Dropping the
    # non-JP CJK faces is the only thing that forces JP glyphs on that path.
    # Hangul and Hanzi still render: the JP faces carry the same glyph set.
    fontconfig.localConf = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
      <fontconfig>
        <selectfont>
          <rejectfont>
            <pattern><patelt name="family"><string>Noto Sans CJK KR</string></patelt></pattern>
            <pattern><patelt name="family"><string>Noto Sans CJK SC</string></patelt></pattern>
            <pattern><patelt name="family"><string>Noto Sans CJK TC</string></patelt></pattern>
            <pattern><patelt name="family"><string>Noto Sans CJK HK</string></patelt></pattern>
            <pattern><patelt name="family"><string>Noto Serif CJK KR</string></patelt></pattern>
            <pattern><patelt name="family"><string>Noto Serif CJK SC</string></patelt></pattern>
            <pattern><patelt name="family"><string>Noto Serif CJK TC</string></patelt></pattern>
            <pattern><patelt name="family"><string>Noto Sans Mono CJK KR</string></patelt></pattern>
            <pattern><patelt name="family"><string>Noto Sans Mono CJK SC</string></patelt></pattern>
            <pattern><patelt name="family"><string>Noto Sans Mono CJK TC</string></patelt></pattern>
            <pattern><patelt name="family"><string>Noto Sans Mono CJK HK</string></patelt></pattern>
          </rejectfont>
        </selectfont>
      </fontconfig>
    '';
  };

  environment.systemPackages = with pkgs; [
    awww
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
    swtpm
    udiskie
    usbutils
  ];
}
