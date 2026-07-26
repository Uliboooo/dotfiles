{ pkgs, ... }:
{
  # ===== desktop base (entire system) =====
  services.desktopManager.gnome.enable = true;
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
  # greetd 経由のログインでも login キーリングを解錠する。これが無いと
  # gcr-ssh-agent が ~/.ssh/id_ed25519 のパスフレーズを取り出せず、GitHub への
  # SSH が署名待ちで固まる（gcr 4.x は askpass GUI を出せないため）。
  security.pam.services.greetd.enableGnomeKeyring = true;

  services.upower.enable = true;

  # greetd + ReGreet(cage 上の GTK4)。GDM をやめた理由:
  #   - ログイン後も greeter セッション(gnome-shell 一式で RSS 約 946MB)が
  #     常駐し続ける。
  #   - その gsd-media-keys が handle-power-key / handle-suspend-key /
  #     handle-hibernate-key を block モードで握り、niri 側の power-key 処理と
  #     競合する。
  #   - gnome-shell と gsd-power が sleep の delay inhibitor を持つため
  #     サスペンド開始が余計に遅れる。
  # ReGreet はログイン時に cage ごと終了し gnome-settings-daemon も持たないので、
  # いずれも起きない。
  #
  # tuigreet ではなく ReGreet を選んだ理由は README/PaperDesign.md 参照。
  # tuigreet は Linux VT 上で動くため 16 色に落ち、paper の色が出せない。
  services.xserver.enable = true;
  services.displayManager.gdm.enable = false;
  # greetd 本体と cage 経由の default_session.command は programs.regreet が
  # mkDefault で設定する。ここで command を書くとそちらが勝つので書かない。
  programs.regreet = {
    enable = true;
    # 既定の cageArgs は [ "-s" "-d" ] で、cage の multi-monitor mode は
    # 未指定だと extend(server.output_mode = 0)。extend では全出力が
    # output_layout に横並びで並び、view_position() が primary view を
    # レイアウト全体(eDP-1 1920x1200 + DP-1 3840x2160 = 5760px 幅)に
    # maximize する。その結果:
    #   - ReGreet のログインカードは「連結レイアウトの中心」= 2 枚の
    #     モニタの継ぎ目付近に置かれ、位置が壊れて見える。
    #   - User/Session のドロップダウンは巨大な surface 基準で配置されるので
    #     ポップオーバがモニタを跨いで開く。
    # -m last で cage は最後に接続された出力だけを有効にし、他を disable
    # するため、greeter は常に 1 枚のモニタ内に収まる(4K を挿していれば
    # そちら、外せば自動で eDP-1 に戻る)。-s -d は既定値なので引き継ぐ。
    cageArgs = [
      "-s"
      "-d"
      "-m"
      "last"
    ];
    font = {
      package = pkgs.monaspace;
      # Waybar / SwayNC と同じ family に揃える。
      name = "Monaspace Radon Var";
      size = 12;
    };
    extraCss = ../.config/greetd/regreet.css;
    settings = {
      # [background] は書かない = 壁紙を敷かず紙面 1 色にする。
      GTK.application_prefer_dark_theme = false;
      appearance.greeting_msg = "welcome back.";
      commands = {
        reboot = [
          "systemctl"
          "reboot"
        ];
        poweroff = [
          "systemctl"
          "poweroff"
        ];
      };
      widget.clock = {
        format = "%Y-%m-%d %a %H:%M";
        resolution = "1s";
        label_width = 260;
      };
    };
  };

  # tuigreet の --sessions と同じ罠。ReGreet は XDG_DATA_DIRS の各要素に
  # /wayland-sessions を足して探すが、greetd.service の環境には
  # XDG_DATA_DIRS が無く、既定値の /usr/share/... は NixOS に存在しない。
  # 結果セッション一覧が空になる。GTK のテーマ/アイコン探索先も兼ねる。
  systemd.services.greetd.environment.XDG_DATA_DIRS = "/run/current-system/sw/share";

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
    # hypridle.conf が /run/current-system/sw/bin から叩くので、ユーザプロファイル
    # ではなくシステム側に入れておく(hypridle.service の PATH は最小限)。
    # brightnessctl = 減光、jq = PipeWire の再生中判定。
    brightnessctl
    jq
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
