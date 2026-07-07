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
    # "x86_64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];
  enableGui = config.dotfiles.enableGui;

  wlmstr = inputs.wlmstr.packages.${pkgs.system}.default;
  tirith = inputs.tirith.packages.${pkgs.system}.default;

  basePackages = with pkgs; [
    # common
    ashell
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
    clang
    llvm
    lld
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
    tailscale
    direnv
    nix-direnv
    typst
    tinymist
    dust
    sioyek
    glow
    # inputs.antigravity.packages.${pkgs.system}.default
    antigravity-cli
    # antigravity
    taplo
    imagemagick
    chafa
    codex
    kdePackages.kdenlive
    noctalia-shell
    pinta
    tirith
  ];

  guiPackages =
    (with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.jetbrains-mono
      libnotify
      mpv
      inkscape
    ])
    ++ lib.optionals chromeSupported [
      pkgs.google-chrome
    ];

  linuxGuiPackages = with pkgs; [
    # Linux-only
    wl-clipboard
    ghostty
    hollywood
    bluetui
    pulsemixer
    brightnessctl
    playerctl
    libreoffice
    nautilus
    loupe
    ffmpegthumbnailer
    clapper
    vlc
    showtime
    wiremix
    mpvpaper
    firefox
    wlmstr
    google-chrome
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
      initContent = ''
        if [ -f "${dotfilesDir}/.zshrc" ]; then
          source "${dotfilesDir}/.zshrc"
        fi
      '';
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

    home.sessionVariables = {
      CC = "clang";
      CXX = "clang++";
      LD = "lld";
    };

    # ===== packages =====
    home.packages =
      basePackages
      ++ lib.optionals enableGui guiPackages
      ++ lib.optionals (enableGui && isLinux) linuxGuiPackages;

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = npmGlobalDir;
      BUN_INSTALL = bunInstallDir;
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
