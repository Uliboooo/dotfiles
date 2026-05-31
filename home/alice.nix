{
  config,
  pkgs,
  inputs,
  ...
}:
let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
  npmGlobalDir = "${config.home.homeDirectory}/.npm-global";
  bunInstallDir = "${config.home.homeDirectory}/.cache/.bun";
  bunBinDir = "${bunInstallDir}/bin";

  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;

  mkConfigLink = name: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/${name}";
in
{
  home.username = "alice";
  home.homeDirectory = pkgs.lib.mkForce (if isDarwin then "/Users/alice" else "/home/alice");
  home.stateVersion = "24.11";

  home.sessionVariables = {
    CC = "clang";
    CXX = "clang++";
    LD = "lld";
  };

  # ===== packages =====
  home.packages =
    with pkgs;
    [
      # common
      git
      neovim
      helix
      kitty
      yazi
      fzf
      fastfetch
      bun
      oils-for-unix
      sheldon
      zsh-abbr
      lazygit
      gh
      zip
      unzip
      coreutils
      gnused
      ghq
      nerd-fonts.symbols-only
      nerd-fonts.jetbrains-mono
      google-chrome
      btop
      difftastic
      tokei
      wget
      go
      gopls
      zig
      zls
      jq
      asciiquarium
      tmux
      tree-sitter
      clang
      llvm
      lld
      restic
      ffmpeg
      mpv
      biome
      stylua
      shfmt
      statix
      deadnix
      nil
      nixfmt
      typescript
      libnotify
      mediainfo
      rust-analyzer
      rustfmt
      cargo
      fd
      ripgrep
      eza
      bat
      inkscape
      nodejs
    ]
    ++ pkgs.lib.optionals isLinux [
      ghostty
      hollywood
      inputs.jolt.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.sampler
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

  home.file.".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.zshrc";
}
