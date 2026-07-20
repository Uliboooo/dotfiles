{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
  npmGlobalDir = "${config.home.homeDirectory}/.npm-global";
  bunInstallDir = "${config.home.homeDirectory}/.cache/.bun";
  bunBinDir = "${bunInstallDir}/bin";

  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
  system = pkgs.stdenv.hostPlatform.system;
  chromeSupported = pkgs.lib.elem system [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
  enableGui = config.dotfiles.enableGui;

  wlmstr = inputs.wlmstr.packages.${system}.default;
  # tirith = inputs.tirith.packages.${pkgs.system}.default;
  zathura-gui = inputs.zathura-gui.packages.${system}.default;
  # shojiwm = inputs.shojiwm.packages.${pkgs.system}.default;
  hyprpanopticon = inputs.hyprpanopticon.packages.${system}.default;

  basePackages = with pkgs; [
    # common
    git
    vim
    neovim
    (if isLinux then emacs-pgtk else emacs)
    helix
    yazi
    fzf
    fastfetch
    bun
    nodejs
    oils-for-unix
    sheldon
    zsh
    zsh-abbr
    lazygit
    gh
    zip
    unzip
    ghq
    btop
    difftastic
    tokei
    wget
    kitty
    go
    gopls
    zig
    zls
    jq
    asciiquarium
    tmux-mem-cpu-load
    tree-sitter
    restic
    ffmpeg
    biome
    stylua
    shfmt
    statix
    deadnix
    nil
    nixfmt
    typescript
    # typescript-language-server
    # vscode-langservers-extracted
    # lua-language-server
    # marksman
    # basedpyright
    # astro-language-server
    # emmet-language-server
    mediainfo
    rust-analyzer
    rustfmt
    cargo
    fd
    ripgrep
    eza
    bat
    direnv
    nix-direnv
    typst
    tinymist
    dust
    glow
    # inputs.antigravity.packages.${pkgs.system}.default
    antigravity-cli
    # antigravity
    taplo
    imagemagick
    chafa
    codex
    # tirith
    claude-code
  ];

  # GUI ではない Linux 専用 CLI。
  linuxPackages = with pkgs; [
    # macOS では Xcode CLT の clang / ld を使う。nixpkgs の clang を profile に
    # 入れると Apple clang を PATH で覆い、SDK/framework 参照が壊れる。
    clang
    llvm
    lld
    # macOS 版は NetworkExtension の entitlement が要るため App 版を使う。
    tailscale
  ];

  # GUI だが GTK に依存しないもの。macOS ではネイティブ (Cocoa) で動く。
  guiPackages =
    (with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.jetbrains-mono
    ])
    ++ lib.optionals chromeSupported [
      pkgs.google-chrome
    ];

  # GTK に依存するものは Linux 限定。darwin でも eval は通るが、GTK ごと
  # ソースビルドになる上に X11/quartz 経由で実用にならない。
  linuxGtkPackages = with pkgs; [
    zathura
    sioyek # Qt だが qtbase の platformtheme 経由で gtk+3 を引く
    pinta
    inkscape
    nautilus
    loupe
    clapper
    showtime
    libreoffice
    firefox
    discord
  ];

  # GUI で macOS 限定。ghostty はソースビルドだと重いので、macOS では
  # ghostty-bin (prebuilt) を使う。
  darwinGuiPackages = with pkgs; [
    ghostty-bin
  ];

  linuxGuiPackages = with pkgs; [
    # Linux-only
    ashell
    noctalia-shell
    kdePackages.kdenlive
    libnotify # freedesktop の D-Bus 通知。macOS には対応する仕組みが無い。
    # mpv は GTK 非依存で meta 上も darwin 対応だが、この nixpkgs では
    # aarch64-darwin のリンクが cctools ld のクラッシュで通らない (Hydra も
    # 同様に失敗するためキャッシュも無い)。macOS では IINA 等を使う。
    mpv
    wl-clipboard
    ghostty
    hollywood
    bluetui
    pulsemixer
    brightnessctl
    playerctl
    ffmpegthumbnailer
    vlc
    wiremix
    mpvpaper
    wlmstr
    zathura-gui
    hyprpanopticon
    # obs-studio
    # shojiwm
  ];

  mkConfigLink = name: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/${name}";
in
{
  options.dotfiles.enableGui = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Install GUI and desktop-related packages.";
  };

  config = {
    home.username = pkgs.lib.mkDefault "seli";
    home.homeDirectory = pkgs.lib.mkDefault (
      if isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}"
    );
    home.stateVersion = "24.11";

    programs.home-manager.enable = true;

    programs.zsh = {
      enable = true;
      dotDir = "${config.home.homeDirectory}/.config/zsh";
      # compinit は dotfiles/.zshrc 側が呼ぶ。non-nix なマシンでも同じ .zshrc を
      # 使うため、そちらを正とする。true にすると compinit が二重に走る。
      enableCompletion = false;
      initContent = ''
        if [ -f "${dotfilesDir}/.zshrc" ]; then
          source "${dotfilesDir}/.zshrc"
        fi
      '';
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
      ];
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    programs.tmux = {
      enable = true;
      package = pkgs.tmux;
      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        battery
        cpu
        resurrect
        continuum
        catppuccin
      ];
      extraConfig = builtins.readFile ../.tmux.conf;
    };

    targets.genericLinux.enable = isLinux;

    # ===== packages =====
    home.packages =
      basePackages
      ++ lib.optionals isLinux linuxPackages
      ++ lib.optionals enableGui guiPackages
      ++ lib.optionals (enableGui && isLinux) (linuxGtkPackages ++ linuxGuiPackages)
      ++ lib.optionals (enableGui && isDarwin) darwinGuiPackages;

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = npmGlobalDir;
      BUN_INSTALL = bunInstallDir;
    }
    // lib.optionalAttrs isLinux {
      # macOS では Xcode CLT の cc/ld に任せる。特に LD=lld は Mach-O の
      # リンクを壊すので darwin では設定しない。
      CC = "clang";
      CXX = "clang++";
      LD = "lld";
    };
    home.sessionPath = [
      "${npmGlobalDir}/bin"
      bunBinDir
    ];

    xdg.enable = true;
    xdg.configFile = {
      "nvim" = {
        source = mkConfigLink "nvim";
        recursive = false;
      };
      "emacs" = {
        source = mkConfigLink "emacs";
        recursive = false;
      };
      "helix" = {
        source = mkConfigLink "helix";
        recursive = false;
      };
      "kitty" = {
        source = mkConfigLink "kitty";
        recursive = false;
      };
      "ghostty" = {
        source = mkConfigLink "ghostty";
        recursive = false;
      };
      "git" = {
        source = mkConfigLink "git";
        recursive = false;
      };
      "yazi" = {
        source = mkConfigLink "yazi";
        recursive = false;
      };
      "nix" = {
        source = mkConfigLink "nix";
        recursive = false;
      };
      "rofi" = {
        source = mkConfigLink "rofi";
        recursive = false;
      };
      "sheldon" = {
        source = mkConfigLink "sheldon";
        recursive = false;
      };
      "zsh-abbr" = {
        source = mkConfigLink "zsh-abbr";
        recursive = false;
      };
      "btop" = {
        source = mkConfigLink "btop";
        recursive = false;
      };
    }
    // pkgs.lib.optionalAttrs isLinux {
      # Linux-only xdg configs (Wayland/Hyprland)
      "hypr" = {
        source = mkConfigLink "hypr";
        recursive = false;
      };
      "niri" = {
        source = mkConfigLink "niri";
        recursive = false;
      };
      "waybar" = {
        source = mkConfigLink "waybar";
        recursive = false;
      };
      "swaync" = {
        source = mkConfigLink "swaync";
        recursive = false;
      };
      "noctalia" = {
        source = mkConfigLink "noctalia";
        recursive = false;
      };
      "nixpkgs" = {
        source = mkConfigLink "nixpkgs";
        recursive = false;
      };
    };

    systemd.user.services.cycle_wallpaper = lib.mkIf isLinux {
      Unit.Description = "wallpaper cycle by awww";

      Service = {
        Type = "oneshot";
        ExecStart = lib.escapeShellArgs [
          (lib.getExe wlmstr)
          "next"
          "seq"
        ];
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };

    systemd.user.timers.cycle_wallpaper = lib.mkIf isLinux {
      Unit.Description = "Change wallpaper every 15 minutes";

      Timer = {
        OnBootSec = "1min";
        OnCalendar = "*-*-* *:00,15,30,45:00";
        Persistent = true;
      };

      Install.WantedBy = [ "timers.target" ];
    };
  };
}
