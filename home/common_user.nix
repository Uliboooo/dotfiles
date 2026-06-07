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

  basePackages = with pkgs; [
    # common
    git
    vim
    neovim
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
    wl-clipboard
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
  ];

  guiPackages =
    (with pkgs; [
      kitty
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
    ghostty
    kitty
    hollywood
    # Linux-only
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
    home.username = pkgs.lib.mkDefault "lilan";
    home.homeDirectory = pkgs.lib.mkForce (
      if isDarwin then
        "/Users/alice" # macOS specific fallback
      else
        "/home/lilan" # Linux specific fallback
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
      "fish" = {
        source = mkConfigLink "fish";
        recursive = false;
      };
      "rofi" = {
        source = mkConfigLink "rofi";
        recursive = false;
      };
      "sampler" = {
        source = mkConfigLink "sampler";
        recursive = false;
      };
      "sheldon" = {
        source = mkConfigLink "sheldon";
        recursive = false;
      };
      "stylua" = {
        source = mkConfigLink "stylua";
        recursive = false;
      };
      "zsh-abbr" = {
        source = mkConfigLink "zsh-abbr";
        recursive = false;
      };
      "cliphist" = {
        source = mkConfigLink "cliphist";
        recursive = false;
      };
    }
    // pkgs.lib.optionalAttrs isLinux {
      # Linux-only xdg configs (Wayland/Hyprland)
      "hypr" = {
        source = mkConfigLink "hypr";
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
      "systemd/user/cycle_wallpaper.service".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/systemd/user/cycle_wallpaper.service";
      "systemd/user/cycle_wallpaper.timer".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/systemd/user/cycle_wallpaper.timer";
      "systemd/user/ssh-agent.service".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/systemd/user/ssh-agent.service";
    };
  };
}
